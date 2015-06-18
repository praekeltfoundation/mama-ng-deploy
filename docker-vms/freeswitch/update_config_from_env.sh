set -e

# 01_sip_dialplan.xml
FILE="/etc/freeswitch/dialplan/public/01_sip_dialplan.xml"
sed -i 's/{{number}}/'"$SIP_NUMBER"'/g' "$FILE"

# sip.xml
FILE="/etc/freeswitch/sip_profiles/external/sip.xml"
sed -i 's/{{username}}/'"$SIP_USERNAME"'/g' "$FILE"
sed -i 's/{{password}}/'"$SIP_PASSWORD"'/g' "$FILE"
sed -i 's/{{realm}}/'"$SIP_SERVER"'/g' "$FILE"
sed -i 's/{{proxy}}/'"$SIP_PROXY"'/g' "$FILE"

