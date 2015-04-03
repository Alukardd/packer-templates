#!/bin/sh -x

URL="http://cdn.selfip.ru/public/cloudinit"
ARCH=""
SUDO="$(which sudo)"

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
    "OpenBSD")
        URL="${URL}-openbsd-${ARCH}"
        ;;
esac


install_systemd() {
$SUDO cat <<EOF > /etc/systemd/system/cloudinit.service
[Unit]
Description=cloudinit
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cloudinit -from-openstack-metadata="http://169.254.169.254/"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
$SUDO systemctl enable cloudinit.service
}

install_cloudinit() {
    grep -q Arch /etc/issue && install_systemd
    grep -q "CentOS Linux 7" /etc/os-release && install_systemd
}


$SUDO curl --progress ${URL} --output /usr/bin/cloudinit
$SUDO chmod +x /usr/bin/cloudinit

install_cloudinit
