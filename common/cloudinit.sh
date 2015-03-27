#!/bin/sh -ex

URL="http://cdn.selfip.ru/public/cloudinit"
ARCH=""

case "$(uname -m)" in
    "x86_64")
        ARCH="x86_64"
        ;;
    "i386")
        ARCH="x86_32"
        ;;
esac

case "$(uname)" in
    "Linux")
        URL="${URL}-linux-${ARCH}"
        ;;
    "FreeBSD")
        URL="${URL}-freebsd-${ARCH}"
        ;;
esac


install_archlinux() {
cat <<EOF > /etc/systemd/system/cloudinit.service
[Unit]
Description=cloudinit
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cloudinit -from-openstack-metadata="http://169.254.269.254/"
ExecStartPost=/usr/bin/systemctl disable cloudinit.service
ExecStartPost=/usr/bin/rm -f /usr/bin/cloudinit /etc/systemd/system/cloudinit.service
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF
systemctl enable cloudinit.service
}

install_cloudinit() {
    grep -q Arch /etc/issue && install_archlinux
}


curl --progress ${URL} > /usr/bin/cloudinit
chmod +x /usr/bin/cloudinit

install_cloudinit
