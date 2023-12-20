#!/usr/bin/bash
IP=$(which ip)
IPTABLES=$(which iptables)
PLUTO_MARK_OUT_ARR=(${PLUTO_MARK_OUT//// })
PLUTO_MARK_IN_ARR=(${PLUTO_MARK_IN//// })

case "$PLUTO_CONNECTION" in

  vti0)
    VTI_INTERFACE=vti0
    VTI_LOCALADDR=10.111.11.2
    VTI_REMOTEADDR=10.111.11.1
    ;;
#  vti1)
#    VTI_INTERFACE=vti1
#    VTI_LOCALADDR=10.111.12.2
#    VTI_REMOTEADDR=10.111.12.1
#    ;;
esac

case "${PLUTO_VERB}" in
    up-client)
        $IP tunnel add ${VTI_INTERFACE} mode vti local ${PLUTO_ME} remote ${PLUTO_PEER} okey ${PLUTO_MARK_OUT_ARR[0]} ikey ${PLUTO_MARK_IN_ARR[0]}
        sysctl -w net.ipv4.conf.${VTI_INTERFACE}.disable_policy=1
        sysctl -w net.ipv4.conf.${VTI_INTERFACE}.rp_filter=2 || sysctl -w net.ipv4.conf.${VTI_INTERFACE}.rp_filter=0
        $IP addr add ${VTI_LOCALADDR} remote ${VTI_REMOTEADDR} dev ${VTI_INTERFACE}
        $IP link set ${VTI_INTERFACE} up mtu 1436
        ip route add 192.168.80.0/24 dev vti0
        ip route add 192.168.70.0/24 dev vti0
#       $IPTABLES -t mangle -I FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
#        $IPTABLES -t mangle -I INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
#        $IP route flush table 220
        #/etc/init.d/bgpd reload || /etc/init.d/quagga force-reload bgpd
        ;;
     down-client)
        #$IP tunnel del ${VTI_INTERFACE}
        $IP link del ${VTI_INTERFACE}
#       $IPTABLES -t mangle -D FORWARD -o ${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
#        $IPTABLES -t mangle -D INPUT -p esp -s ${PLUTO_PEER} -d ${PLUTO_ME} -j MARK --set-xmark ${PLUTO_MARK_IN}
        ;;
esac
