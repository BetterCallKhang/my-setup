### Just do this shit (work on CachyOS, the others never test)

nmcli connection add type wifi con-name FU-Students ifname wlan0 ssid FU-Students \
802-11-wireless-security.key-mgmt wpa-eap \
802-1x.eap peap \
802-1x.phase2-auth mschapv2 \
802-1x.identity "username" \
802-1x.password "password" \
802-1x.password-flags 0 \
802-1x.system-ca-certs no

nmcli connection up FU-Students