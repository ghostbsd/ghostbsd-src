# GhostBSD CI for OpenRC

This folder contains scripts to install ghostbsd into a bhyve-vm, and apply changes from libexec/rc/etc/etc.init.d for regression testing.  Testing adding, removing services from runlevels, or other chnages are out of scope.  When the job completes the VM will shutdown safely, logs will be artifacted into this directory of the source tree, and are ignored by gitignore facility.

## Requirements
* GhostBSD development image installed
* Host capable of running vm-bhyve with expect installed.

## Running tests

```
sudo ./runtests.sh
```
