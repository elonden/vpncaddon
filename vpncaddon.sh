#!/bin/env bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


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
	for x in "${addr[@]}"; do
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



