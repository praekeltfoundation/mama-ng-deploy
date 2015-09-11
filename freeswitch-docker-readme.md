# Freeswitch in Docker

The goal of this README is to document the process to create the freeswitch
docker image, explain decisions that were made, and give some helpful hints
and tips for debugging with docker and freeswitch.

The goal of the freeswitch docker image is to create a freeswitch that has a
[Twilio SIP Trunk][1] as its SIP provider, and links up to the
[Vumi Freeswitch Transport][2] to send and receive voice and IVR messages over
AMQP.

**Table of contents**

1. [Docker image](#docker-image)  --
   Explains the Dockerfile and how to create it
2. [Freeswitch configuration](#freeswitch-config)  --
   Explains the freeswitch configuration files
3. [Running the image](#run-image)  --
   Explains the commands to run the docker image
4. [Freeswitch and Docker debugging hints and tips](#hints-and-tips)  --
   Gives helpful commands when debugging the freeswitch docker image

[1]: https://www.twilio.com/sip-trunking
[2]: https://github.com/praekelt/vumi-freeswitch-esl

## Docker image<a name="docker-image"></a>
The docker image is created using a [Dockerfile][3] available
[in this repository][4]. This section will go through this file and explain
each of the steps.

```Dockerfile
FROM debian:wheezy
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>
```

The preferred [official freeswitch installation instructions][5] are for
Debian 7 (Wheezy), so we chose that as the basis for our docker image.

```Dockerfile
RUN echo 'deb http://files.freeswitch.org/repo/deb/debian/ wheezy main' \
    >> /etc/apt/sources.list.d/freeswitch.list
RUN gpg --keyserver pool.sks-keyservers.net --recv-key D76EDC7725E010CF
RUN gpg -a --export D76EDC7725E010CF | apt-key add -
```

These three steps are from the [official instructions][5]. They add the APT
repository to the sources list, and import the repository signing key.

```Dockerfile
ADD retry_until_pass.sh ./
RUN ./retry_until_pass.sh apt-get update
RUN ./retry_until_pass.sh apt-get install -y freeswitch-meta-vanilla freeswitch-mod-flite
```

We then add the [retry\_until\_pass script][6]. This script retries a command
until the command passes. This was mainly to facilitate building and testing
locally, but is also useful for general building of the image.

The freeswitch debian packages have a lot of induvidual packages, some of them
quite large. If a download fails or times out when installing usually, you can
retry the command, and it uses the cache for all the previous files it managed
to successfully download.

With docker, however, if one of the steps fails, the build fails, and all the
caching that apt-get does is thrown away. So if a download on one of the files
fails, you have to redownload all of them again.

This was frustrating, so the [retry\_until\_pass script][6] was created to get
around this point.

We install the `freeswitch-meta-vanilla` package, which contains a basic
setup of freeswitch packages needed for a normal freeswitch install. We also
install the `freeswitch-mod-flite` package, to provide us with a text to
speech engine.

```Dockerfile
RUN cp -a /usr/share/freeswitch/conf/vanilla/. /etc/freeswitch/
COPY config/ /etc/freeswitch/
```

We then copy the default configuration files to the freeswitch configuration
folder. This is also an instruction from the
[official installation instructions][5].

Afterwards, we override the default files with files from the local folder
`config`. This allows us to use all the default configuration, and modify
it where we want to. More information on what was changed from the default
config can be found in the [configuration section](#freeswitch-config)

```Dockerfile
EXPOSE 1719/udp 1720/tcp 3478/udp 3479/udp
EXPOSE 5002/tcp 5003/tcp
EXPOSE 5060/tcp 5060/udp 5070/tcp 5070/udp 5080/tcp 5080/udp
EXPOSE 8021/tcp
EXPOSE 16384-32768/udp
EXPOSE 5066/tcp 7443/tcp
```

We then expose all the ports required by Freeswitch. This list is compiled
from [the firewall section of the Freeswitch documentation][7].

```Dockerfile
CMD stdbuf -i0 -o0 -e0 /usr/bin/freeswitch -c
```

This last line runs freeswitch and attaches to the console (given by the -c
option).

With Freeswitch in docker, we run into the problem that not all of the console
gets completely flushed, so when looking at the output, the bottom is not
visible. We use the command line tool [stdbuf][8] to rectify this. We set the
input stream (-i0), output stream (-o0), and error stream (-e0) buffering to
zero, which gives us the full output from the Freeswitch console.

Finally, to build the docker image, the following command can be used:

```bash
docker build -t freeswitch docker-vms/freeswitch
```


[3]: https://docs.docker.com/reference/builder/
[4]: https://github.com/praekelt/mama-ng-deploy/blob/develop/docker-vms/freeswitch/Dockerfile
[5]: https://freeswitch.org/confluence/display/FREESWITCH/Debian+7#Debian7-DebianPackage
[6]: https://github.com/praekelt/mama-ng-deploy/blob/develop/docker-vms/freeswitch/retry_until_pass.sh
[7]: https://freeswitch.org/confluence/display/FREESWITCH/Firewall
[8]: http://linux.die.net/man/1/stdbuf

## Freeswitch configuration<a name="freeswitch-config"></a>
For the Freeswitch configuration, we use the default configuration setup, and
modify certain parts to suite our needs. Unfortunately, most of these config
files contain sensitive passwords and information, and are stored in a private
repository. For the files that we can share, links are provided. For private
files, the changes from the default configuration will be shown here, with
the sensitive information replaced.

All the paths given are relative to the `config` folder, and inside of the
Docker container, they are relative to `/etc/freeswitch/`.

###[autoload_configs/modules.conf.xml][9]

In order to use the text to speech module, we need to add it to modules.conf.
The following line was added:

```xml
<load module="mod_flite"/>
```

###dialplan/01_twilio_dialplan.xml

This is where the dialplan for the twilio connection is placed. This is a new
file created with the following content:

```xml
<include>
    <extension name="twilio.inbound">
        <condition field="destination_number" expression="^(\+27xxxxxxxxx)$">
            <action application="log" data="INFO DIALING Extension sip.inbound From [${sip_from_user}] To [${sip_to_user}] with Destination Number [${destination_number}]."/>
            <action application="socket" data="127.0.0.1:8051 async full"/>
        </condition>
    </extension>
</include>
```

The `destination_number` condition field sets the regex to match for this rule.
We set it to exactly match our Twilio number.

Then there are two actions. The first create a log entry with some information
that can be useful for debugging. The second connects to the Freeswitch
Vumi transport, which has been set up to be on port 8051. The IP is set to
the localhost, as we connect the transport container to this container via
`--net=freeswitch`, so that they share the same networking stack. This is done
because the transport needs to connect to freeswitch, and freeswitch needs to
connect to the transport (bi-directional connection).

###sip_profiles/external/twilio.xml

This is where the SIP Profile for Twilio is placed. This is a new file created
with the following content:

```xml
<include>
    <gateway name="twilio">
        <param name="username" value="xxxxxxxxxxx"/>
        <param name="password" value="xxxxxxxxxxx" />
        <param name="proxy" value="xxxxxxxxxx.pstn.twilio.com"/>
        <param name="realm" value="sip.twilio.com"/>
        <param name="register" value="false"/>
        <param name="caller-id-in-from" value="true"/>
    </gateway>
</include>
```

Here is where you place the Twilio authentication information. This information
is set in Twilio when you set up the SIP trunk. There are very useful
[official instructions][10] on how to do this.

The `realm` is set to `sip.twilio.com`. This is for digest auth, which we
could not get working properly, so we are using ACL auth. More information on
that can be found in the section dealing with the ACL auth configuration file.

###sip_profiles/internal.xml

For this file we use mostly the default file with a few changes. The following
two lines are changed:

```xml
<param name="ext-rtp-ip" value="xxx.xxx.xxx.xxx"/>
<param name="ext-sip-ip" value="xxx.xxx.xxx.xxx"/>
```

By default freeswitch uses STUN to find the external IP address. This, however,
does not work from within Docker, so we have to manually set these values to
the external server IP address.

###sip_profiles/external.xml

We have to do a similar change here as with `internal.xml`. The following two
lines are changed:

```xml
<param name="ext-rtp-ip" value="xxx.xxx.xxx.xxx"/>
<param name="ext-sip-ip" value="xxx.xxx.xxx.xxx"/>
```

###autoload_configs/switch.conf.xml

In this file, we limit the amount of UDP ports used for SIP. This is explained
further in the [Running the image](#run-image) section. The following lines are
changed:

```xml
<param name="rtp-start-port" value="16384"/>
<param name="rtp-end-port" value="16394"/>
```

Here we open 10 ports for SIP, which will allow for 10 simultaneous calls.
You might want to increase this, depending on how many simultaneous calls you
need.

###autoload_configs/acl.conf.xml

Since we could not get digest auth working, we just added a list of Twilio IP
addresses the this file. The following was added:

```xml
<list name="domains" default="deny">
  <node type="allow" cidr="54.172.60.0/23"/>
  <node type="allow" cidr="54.171.127.192/26"/>
  <node type="allow" cidr="54.65.63.192/26"/>
  <node type="allow" cidr="54.169.127.128/26"/>
  <node type="allow" cidr="54.252.254.64/26"/>
  <node type="allow" cidr="177.71.206.192/26"/>
</list>
```

The default "domains" list was also removed.


[9]: https://github.com/praekelt/mama-ng-deploy/blob/develop/docker-vms/freeswitch/config/autoload_configs/modules.conf.xml
[10]: https://www.twilio.com/docs/sip-trunking/getting-started

## Running the image<a name="run-image"></a>
To run the image, the following command can be used:

```bash
docker run --rm --name=freeswitch --link redis:redis --link rabbitmq:rabbitmq -p 8021:8021 -p 5060-5061:5060-5061/tcp -p 5060-5061:5060-5061/udp -p 5080:5080/tcp -p 5080:5080/udp -p 16384-16394:16384-16394/udp freeswitch
```

Lets break this command up into stages.

First `docker run --rm` runs a docker container, and automatically cleans it
up when it exits.

`--name=freeswitch` gives it the name `freeswitch`. If you do not give your
container a name, then it will get an automatically generated name like
`hungry_meitner`. We give it a name so that it is easier to refer to.

`--link redis:redis --link rabbitmq:rabbitmq`. This links the container to the
Redis and RabbitMQ containers. Now Freeswitch does not need either of those,
but the Vumi transport does. And we cannot `--link` on the Vumi transport,
because we are using `--net=freeswitch`. So we have to link those containers to
the Freeswitch container for the Vumi transport to have access to them.

`-p 8021:8021 -p 5060-5061:5060-5061/tcp -p 5060-5061:5060-5061/udp -p 5080:5080/tcp -p 5080:5080/udp` 
This connects the various Freeswitch control ports to the outside world. A full
list of Freeswitch ports can be found in the [firewall section][7] of the docs.

`-p 163834-16394:16384:16394/udp`. This links the 10 UDP ports used for calls
to the outside world.

Originally, we had tried to map all 16384 ports, but Docker launches a proxy
process for each mapped port which takes up about 11MB of RAM. So for 16384
ports, it tries to take 176GB of memory, so it just freezes the whole machine.

You can disable this proxy by adding the `--userland-proxy=false` to the
`DOCKER_OPTS` in `/etc/default/docker`. We tried this, but the docker process
still froze and we were unable to interact with it.

So the solution we came up with involved limiting the amount of ports that were
mapped. Since this is for a QA instance, we limited the amount of ports to 10,
which would allow for 10 simultaneous calls. This requires changes in both the
run command and the Freeswitch config, detailed in the
[config section](#freeswitch-config).


## Freeswitch and Docker debugging hints and tips<a name="hints-and-tips"</a>

This section comprises of a few helpful commands that were discovered when
debugging various problems with running Freeswitch in a Docker container.

`docker run --rm freeswitch cat /etc/freeswitch/config_file.xml > config_file.xml`
Allows you to get a default Freeswitch config file, so that you can edit it
and add it to the config folder.

`docker exec -it freeswitch bash` will allow you to attach a new console to
and existing container, so you can poke around in the container while it is
running freeswitch.

Once you are attached to the container, you can run `fs_cli` to attach to the
Freeswitch command line interface and type commands.

Two commands that are useful are `console loglevel debug`, which makes the
console show the debugging logs, which can be userful, and
`sofia global siptrace on`, which shows you exactly what is being sent and
received for SIP, which is also useful for debugging.
