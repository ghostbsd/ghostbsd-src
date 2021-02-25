#!/bin/sh

check_requirements()
{
  # Check that we are running as root or with sudo
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo" 1>&2
    exit 1
  fi

  # Check for required packages
  PACKAGES="vm-bhyve expect"

  # Check for 13.0-STABLE kernel

  # Check for GhostBSD repo

  # Check for vm-bhyve

  # Check to make sure vm-bhyve modules are loaded and vm service is started
}

poweroff_vm()
{
  # Check for previously running ghostbsd-openrc-ci vm and power off
}

stop_console_session()
{
  # Stop any previous ghostbsd-openrc-ci vm console sessions
}

export_pool()
{
  # Export pool
}

unmount_disk_image()
{
  # Unmount disk image
}

cleanup()
{
  # Cleanup any previous ghostbsd-openrc-ci vm data
}

create_vm()
{
  # Get the location of vm_dir from rc.conf

  # Always copy the ghostbsd-core-ci template to vm_dir

  # Check vm-bhyve to determine which switch is default

  # Enable the default switch in ghostbsd-core-ci template in vm_dir location

  # Create ghostbsd-openrc-ci vm
}

mount_disk_image()
{
  # Mount ghostbsd-openrc-ci disk image
}

create_pool()
{
  # Create partitions in disk image

  # Image bootloader

  # Create pool
}

import_pool()
{
  # Import pool for ghostbsd-openrc-ci
}

install_os_packages()
{
  # Install 13-stable packages in disk image
}

install_repo_overlay()
{
  # Copy libexec/rc/etc.init.d/ contents to /etc/init.d/ in disk image
}

boot_vm()
{
  # start the vm
}

start_console_session()
{
  # Begin console session

  # Login as root

  # Run command to print deptree to log
}

shutdown_vm()
{
  # Cleanly shutdown the vm to get shutdown logs properly
}

get_logs()
{
  # Grab /var/log/rc.log

  # Grab deptree log
}

check_logs()
{
  # Check for any errors in /var/rc.log and return 0 or 1

  # Present messaging on how to start vm and console in if any problems were encountered
}

# Run our functions
check_requirements
poweroff_vm
stop_console_session
export_pool
unmount_disk_image
mount_disk_image
create_pool
import_pool
install_os_packages
install_repo_overlay
boot_vm
start_console_session
shutdown_vm
stop_console_session
import_pool
get_logs
export_pool
unmount_disk_image
check_logs
