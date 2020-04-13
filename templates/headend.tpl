hostname="${hostname}"
ios-config-1="!"
ios-config-2="no ip domain-lookup"
ios-config-3="crypto keyring Internet"
ios-config-4="  pre-shared-key address 0.0.0.0 0.0.0.0 key ${isakmp_key}"
ios-config-5="!"
ios-config-6="!"
ios-config-7="crypto isakmp profile dmvpn-tun0"
ios-config-8="   keyring Internet"
ios-config-9="   match identity address 0.0.0.0"
ios-config-10="   local-address GigabitEthernet1"
ios-config-11="crypto isakmp policy 10"
ios-config-12=" encr aes 256"
ios-config-13=" authentication pre-share"
ios-config-14=" group 2"
ios-config-15="crypto isakmp invalid-spi-recovery"
ios-config-16="crypto isakmp keepalive 45"
ios-config-17="crypto isakmp nat keepalive 45"
ios-config-18="crypto isakmp aggressive-mode disable"
ios-config-19="!"
ios-config-20="crypto ipsec security-association replay window-size 512"
ios-config-21="crypto ipsec nat-transparency udp-encapsulation"
ios-config-22="!"
ios-config-23="crypto ipsec transform-set outbound esp-aes 256 esp-sha-hmac"
ios-config-24=" mode transport"
ios-config-25="!"
ios-config-26="!"
ios-config-27="crypto ipsec profile vpnprofile"
ios-config-28=" set transform-set outbound"
ios-config-29=" local-address GigabitEthernet1"
ios-config-30="!"
ios-config-31="!"
ios-config-32="interface Tunnel1"
ios-config-33=" no shutdown"
ios-config-34=" description T0 DWVPN mtu 1400 mss 1360"
ios-config-35=" bandwidth 1000000"
ios-config-36=" ip address ${tunnel_ip} 255.255.255.0"
ios-config-37=" no ip redirects"
ios-config-38=" ip mtu 1400"
ios-config-39=" no ip split-horizon eigrp 100"
ios-config-40=" ip nhrp authentication ${nhrp_authentication_key}"
ios-config-41=" ip nhrp network-id 100"
ios-config-42=" ip nhrp holdtime 60"
ios-config-43=" ip tcp adjust-mss 1360"
ios-config-44=" tunnel source GigabitEthernet1"
ios-config-45=" tunnel mode gre multipoint"
ios-config-46=" tunnel key ${tunnel_key}"
ios-config-47=" tunnel protection ipsec profile vpnprofile shared "
ios-config-48="interface GigabitEthernet2"
ios-config-49=" no shutdown"
ios-config-50=" ip address dhcp"
ios-config-51=" ip nat inside"
ios-config-52="interface GigabitEthernet1"
ios-config-53=" ip nat outside"
ios-config-54="router eigrp 100"
ios-config-55=" no auto-summary"
ios-config-56=" network 10.0.0.0 0.255.255.255"
ios-config-57=" network 192.168.1.0 0.0.0.255"
ios-config-58=" redistribute static"
ios-config-59="ip nat inside source static tcp ${consul_ip} 22 interface GigabitEthernet1 2022"
ios-config-60="ip nat inside source static tcp ${consul_ip} 8500 interface GigabitEthernet1 8500"
ios-config-61="ip nat inside source static tcp ${consul_ip} 9094 interface GigabitEthernet1 8000"
ios-config-62="ip route ${internal_route} ${vpc_router}

