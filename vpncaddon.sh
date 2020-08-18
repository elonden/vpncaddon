#!/bin/env bash

# Primarily used to have okta.com return traffic over the VPN tunnel to avoid constant MFA request

set -o noglob
declare -a dom
declare -a addr
dom=(okta.com mtls.okta.com oktapreview.com mtls.oktapreview.com oktacdn.com okta-emea.com mtls.okta-emea.com login.okta.com )

# Add ip addresses to the VPN include list

vpn() {
# Call the standard vpn-script
. /etc/vpnc/vpnc-script
exit
}


add_ip () {
	export CISCO_SPLIT_INC_${CISCO_SPLIT_INC}_ADDR=$1
    export CISCO_SPLIT_INC_${CISCO_SPLIT_INC}_MASK=255.255.255.255
    export CISCO_SPLIT_INC_${CISCO_SPLIT_INC}_MASKLEN=32
    export CISCO_SPLIT_INC=$(($CISCO_SPLIT_INC + 1))
}


rundom() {
for i in "${dom[@]}";
do
    addr=$(dig +short ${i} | egrep "^[0-9]")
	for x in ${addr[@]}; do
		if [[ "${x}" != "" ]]; then
			add_ip "${x}"
		fi
	done
done
}

case "${reason}" in
		disconnect)
				vpn
				;;
		connect)
				rundom
				vpn
				;;
esac



