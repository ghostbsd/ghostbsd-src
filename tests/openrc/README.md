# GhostBSD CI for OpenRC

This folder contains scripts to install ghostbsd into a bhyve-vm, and apply changes from libexec/rc/etc/etc.init.d for regression testing.  

## Requirements
* GhostBSD development image installed
* Host capable of running vm-bhyve with expect installed.

## Running tests

```
sudo ./runtests.sh
```
