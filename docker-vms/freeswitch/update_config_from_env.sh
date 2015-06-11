set -e

# 01_sip_dialplan.xml
FILE="dialplan/public/01_sip_dialplan.xml"
sed -i 's/{{number}}/'"$SIP_NUMBER"'/' "$FILE"

# sip.xml
FILE="sip_profiles/external/sip.xml"
sed -i 's/{{username}}/'"$SIP_USERNAME"'/' "$FILE"
sed -i 's/{{password}}/'"$SIP_PASSWORD"'/' "$FILE"
sed -i 's/{{realm}}/'"$SIP_SERVER"'/' "$FILE"
sed -i 's/{{proxy}}/'"$SIP_PROXY"'/' "$FILE"

