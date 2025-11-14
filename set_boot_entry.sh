#!/usr/bin/bash

if [[ ! -d /sys/firmware/efi/ ]]; then
    exit 0
fi

. /etc/os-release
DISTRO=$(echo ${ID} | sed -e 's/rhel/redhat/' -e 's/\"//')

if [[ -n $@ ]]; then
    DISTRO=${1}
fi

ESP_DIR_A=/boot/efi/EFI/${DISTRO}
ESP_DIR_B=/boot/efi/EFI/${DISTRO}/b

ENTRY=$(efibootmgr | grep BootCurrent | cut -d':' -f2)
efibootmgr | grep $ENTRY | grep -q "_new"
result=$(echo $?)

if [ $result -eq 0 ]; then
    FROM_DIR=${ESP_DIR_B}
    TO_DIR=${ESP_DIR_A}
else
    FROM_DIR=${ESP_DIR_A}
    TO_DIR=${ESP_DIR_B}
    # need to warn user that new entry failed to boot
    echo "[$(date '+%H:%M:%S  %d-%m-%Y')] new entry failed to boot" >> /var/log/bootupdate.log
fi

cp ${FROM_DIR}/* ${TO_DIR}/.
