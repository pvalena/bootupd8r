#!/bin/bash

if [[ ! -d /sys/firmware/efi/ ]]; then
    exit 0
fi

. /etc/os-release
DISTRO=$(echo ${ID} | sed -e 's/rhel/redhat/' -e 's/\"//')

ARCH=$(uname -m)
AR=x64
if [[ ${ARCH} == aarch64 ]]; then
  AR=aa64
fi

ESP_DIR_A=/boot/efi/EFI/${DISTRO}
ESP_DIR_B=/boot/efi/EFI/${DISTRO}/b

# default settings
NAME=${DISTRO}
EFI_DEV=$(lsblk -l | grep efi | cut -d' ' -f1)
PARTITION=$(echo ${EFI_DEV} | rev | grep -o "^[0-9]*" | rev)
DEVICE=$(lsblk -l | grep -B1 efi | grep disk | cut -d' ' -f1)
DEVICE="/dev/${DEVICE}"
EFI_PATH=\EFI\${DISTRO}\shim${AR}.efi

parse_string() {
  for i in "$@"; do
    shift
    if [[ $1 == "-L" ]]; then
      shift
      NAME=${1}
    elif [[ $1 == "-d" ]]; then
      shift
      DEVICE=${1}
    elif [[ $1 == "-p" ]]; then
      shift
      PARTITION=${1}
    elif [[ $1 == "-l" ]]; then
      shift
      EFI_PATH=${1}
    fi 
  done
}

if [ ! -d ${ESP_DIR_B} ]; then
    # create directory for new entry and copy binaries there
    mkdir -p ${ESP_DIR_B}
    cp ${ESP_DIR_A}/* ${ESP_DIR_B}/.
  
    INSTALL_LOG=/var/log/anaconda/storage.log
    if [[ -f /usr/lib/bootloader/bl.cfg ]]; then
        . /usr/lib/bootloader/bl.cfg
    elif [[ -f $INSTALL_LOG ]]; then
        EFI_ENTRY=$(grep "efibootmgr " $INSTALL_LOG | cut -d' ' -f5-)
        parse_string ${EFI_ENTRY}
    fi
    EFI_PATH=$(echo $EFI_PATH | sed -e "s/${DISTRO}\\\s/${DISTRO}\\\b\\\s/" -e 's/\\/\\\\/g')
  
    # create entry for new EFI_PATH
    if [[ -n CMDLINE ]]; then
    # TODO / FINISH
        echo -n "\nmbl-cloud.uki $(echo $BOOT_OPTIONS) boot=$(awk '/ \/boot / {print $1}' /etc/fstab) rd.system.gpt_auto=0" | iconv -f UTF8 -t UCS-2LE | efibootmgr -C -d ${DEVICE} -p ${PARTITION} -L ${NAME}_new -l /EFI/${DISTRO}/b/shim${AR}.efi -@ -
    else
        efibootmgr -C -w -L ${NAME}_new -d ${DEVICE} -p ${PARTITION} -l ${EFI_PATH}
    fi
fi
