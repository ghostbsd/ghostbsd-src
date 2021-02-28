#!/bin/sh

# Set global variables
CWD=$(realpath | sed 's|/scripts||g')

check_requirements()
{
  # Check that we are running as root or with sudo
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo" 1>&2
    exit 1
  fi

  # Todo check for required packages
  PACKAGES="vm-bhyve expect"

  # Todo Check to make sure vm-bhyve modules are loaded and vm service is started
}

poweroff_vm()
{
  # Check for previously running ghostbsd-openrc-ci vm and power off
  yes | vm poweroff ghostbsd-openrc-ci  >/dev/null 2>/dev/null || true
  while : ; do
    [ ! -e "/dev/vmm/ghostbsd-openrc-ci" ] && break
    sleep 1
  done
}

stop_console_session()
{
  # Stop any previous ghostbsd-openrc-ci vm console sessions
  ps -auwx | grep cu | grep ghostbsd | awk '{print $2}' | xargs kill -9 >/dev/null 2>/dev/null || true
  # Todo also add cleanup for expect process
}

detach_disk_image()
{
  # Unmount disk image
  umount -f /tmp/ghostbsd-openrc-ci-efi >/dev/null 2>/dev/null || true
  zpool export -F ghostbsd-openrc-ci >/dev/null 2>/dev/null || true
  mdconfig -d -u 99 >/dev/null 2>/dev/null || true
}

cleanup_vm()
{
  # Cleanup any previous ghostbsd-openrc-ci vm data
  yes | vm destroy ghostbsd-openrc-ci >/dev/null 2>/dev/null || true
}

create_vm()
{
  # Get the location of vm_dir from rc.conf
  VM_DIR=$(sysrc -q -n vm_dir)
  if [ "$VM_DIR" = "" ]; then
    # Fail if vm_dir is not set in /etc/rc.conf
    echo "vm_dir is not set in /etc/rc.conf"
    exit 1
  else
    # Print out the value of vm_dir in /etc/rc.conf 
    echo "vm_dir is set to ${VM_DIR} in /etc/rc.conf"
  fi

  # Always copy the ghostbsd-openrc-ci template to the local directory specified vm_dir
  # Check to see if zfs is used for vm_dir parameter in /etc/rc.conf
  echo "${VM_DIR}" | grep -q zfs
  if [ $? -ne 1 ]; then
    # Get and use the filesystem path for the zfs dataset for copying the template
    VM_DIR_ZFS=$(echo "${VM_DIR}" | grep -o '/.*')
    cp ${CWD}/ghostbsd-openrc-ci.conf ${VM_DIR_ZFS}/.templates/
    echo "Copied ghostbsd-openrc-ci.conf template to ${VM_DIR_ZFS}/.templates/"
  else
    # Use the filesystem path specified by vm_dir in /etc/rc.conf
    cp ${CWD}/ghostbsd-openrc-ci.conf ${VM_DIR}
    echo "Copied ghostbsd-openrc-ci.conf template to ${VM_DIR}/.templates/"
  fi

  # Check vm-bhyve to determine which switch is default
  # Check to see if zfs is used for vm_dir parameter in /etc/rc.conf
  echo "${VM_DIR}" | grep -q zfs
  if [ $? -ne 1 ]; then
    # Get and use the filesystem path for the zfs dataset for copying the template
    # Enable the default switch in ghostbsd-core-ci template in vm_dir location
    SWITCH=$(vm switch list | awk 'FNR==2{print $0}' | awk '{print $1}')
    sed -i '' -e 's/changeme/'${SWITCH}'/' ${VM_DIR_ZFS}/.templates/ghostbsd-openrc-ci.conf
  else
    # Use the filesystem path specified by vm_dir in /etc/rc.conf
    # Enable the default switch in ghostbsd-core-ci template in vm_dir location
    SWITCH=$(vm switch list | awk 'FNR==2{print $0}' | awk '{print $1}')
    sed -i '' -e 's/changeme/'${SWITCH}'/' ${VM_DIR}/.templates/ghostbsd-openrc-ci.conf
  fi

  # Create ghostbsd-openrc-ci vm
  vm create -t ghostbsd-openrc-ci ghostbsd-openrc-ci
}

attach_disk_image()
{
  # Mount ghostbsd-openrc-ci disk image
  # Check to see if zfs is used for vm_dir parameter in /etc/rc.conf
  echo "${VM_DIR}" | grep -q zfs
  if [ $? -ne 1 ]; then
    # Get and use the filesystem path for the zfs dataset for mounting the vm disk
    VM_DIR_ZFS=$(echo "${VM_DIR}" | grep -o '/.*')
    mdconfig -f "${VM_DIR_ZFS}/ghostbsd-openrc-ci/disk0.img" -u 99
  else
    # Use the filesystem path specified by vm_dir in /etc/rc.conf for mounting the vm disk
    mdconfig -f "${VM_DIR}/ghostbsd-openrc-ci/disk0.img" -u 99 
  fi
}

create_pool()
{
  # Create partitions in disk image using vm disk image
  gpart create -s gpt /dev/md99
  gpart add -s 1000K -t efi /dev/md99
  gpart add -a 1m -t freebsd-zfs -l rootfs /dev/md99

  # Prepare the EFI partition using vm disk image
  newfs_msdos md99p1
  if [ ! -d "/tmp/ghostbsd-openrc-ci-efi" ] ; then
    mkdir /tmp/ghostbsd-openrc-ci-efi
  fi
  mount -t msdosfs /dev/md99p1 /tmp/ghostbsd-openrc-ci-efi
  mkdir -p /tmp/ghostbsd-openrc-ci-efi/efi/boot/
  cp /boot/loader.efi /tmp/ghostbsd-openrc-ci-efi/efi/boot/BOOTx64.efi
  mkdir -p /tmp/ghostbsd-openrc-ci-efi/boot
  # Do not indent the lines below cat we need to preserve formatting for loader.rc
  cat > /tmp/ghostbsd-openrc-ci-efi/boot/loader.rc << EOF
unload
set currdev=zfs:ghostbsd-openrc-ci/ROOT/initial:
load boot/kernel/kernel
load boot/kernel/zfs.ko
autoboot
EOF

  # Create ghostbsd-openrc-ci pool using vm disk image
  if [ ! -d "/tmp/ghostbsd-openrc-ci-pool" ] ; then
    mkdir -p /tmo/ghostbsd-openrc-ci-pool
  fi
  zpool create -f -m none -o altroot=/tmp/ghostbsd-openrc-ci-pool ghostbsd-openrc-ci md99p2
  zfs create ghostbsd-openrc-ci/ROOT
  zfs create ghostbsd-openrc-ci/ROOT/initial
  zfs set mountpoint=/ ghostbsd-openrc-ci/ROOT/initial
  zpool set bootfs=ghostbsd-openrc-ci/ROOT/initial ghostbsd-openrc-ci
  zfs mount -a
}

install_os_packages()
{
  # Install 13-stable packages in disk image
  PACKAGES="os-generic-kernel os-generic-userland"
  pkg-static -r /tmp/ghostbsd-openrc-ci-pool install -y -g ${PACKAGES}
}

install_repo_changes()
{
  # Copy special loader.conf to enable zfs but disable boot mute
  cp ${CWD}/loader.conf /tmp/ghostbsd-openrc-ci-pool/boot/

  # Copy special rc.conf to setup network
  cp ${CWD}/rc.conf /tmp/ghostbsd-openrc-ci-pool/etc/

  # Copy ../../libexec/rc/etc.init.d/ contents to /etc/init.d/ in disk image
  cp -R ${CWD}/../../libexec/rc/etc.init.d/ /tmp/ghostbsd-openrc-ci-pool/etc/init.d/

  # Copy ../../sbin/devd/devmatch-openrc.conf to /etc/devd-openrc/ in disk image
  cp ${CWD}/../../sbin/devd/devmatch-openrc.conf /tmp/ghostbsd-openrc-ci-pool/etc/devd-openrc/
}

boot_vm()
{
  # start the vm
  vm start ghostbsd-openrc-ci
}

start_console_session()
{
  # Begin console session
  expect ${CWD}/runtests.exp /dev/nmdm-ghostbsd-openrc-ci.1B /tmp/ghostbsd-openrc-ci.output ghostbsd-openrc-ci
}

# Run our functions
check_requirements
poweroff_vm
stop_console_session
detach_disk_image
cleanup_vm
create_vm
attach_disk_image
create_pool
install_os_packages
install_repo_changes
detach_disk_image
boot_vm
start_console_session
