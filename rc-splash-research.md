# RC-Level Splash Screen Research

## Goal

Keep the boot splash visible during RC service startup, not just during kernel boot.

## How boot_mute Works

`boot_mute="YES"` in `loader.conf` sets the `RB_MUTE` flag in the kernel's `boothowto`.
This sets `cn_mute = 1` in `sys/kern/kern_cons.c`, suppressing all console output.

## The Key Discovery

The kernel exposes console muting as a read/write sysctl:

```c
// sys/kern/kern_cons.c:107
SYSCTL_INT(_kern, OID_AUTO, consmute, CTLFLAG_RW, &cn_mute, 0, ...);
```

This means `kern.consmute` can be set from userspace at any time — including from RC scripts.

## Proposed Approach

No new kernel code required. Wire it up via two rc.d scripts:

**Early RC script** (ordered before most services):
```sh
sysctl kern.consmute=1
```

**Late RC script** (just before display manager starts):
```sh
sysctl kern.consmute=0
```

Combined with `boot_mute="YES"` in `loader.conf`, this would keep the framebuffer
splash visible from loader → kernel boot → entire RC phase, clearing only when the
desktop/login is ready.

## Limitations

- `vidcontrol` does not work with `vt(4)` — not a viable option
- No Plymouth equivalent exists on FreeBSD
- The splash itself is still the loader-level framebuffer image; this approach just
  prevents anything from overwriting it during RC

## Files of Interest

- `sys/kern/kern_cons.c` — `cn_mute`, `kern.consmute` sysctl, `RB_MUTE` handling
- `sys/dev/vt/vt_core.c:1685` — VT checks `RB_MUTE` flag
- `sys/sys/reboot.h` — `RB_MUTE` and `RB_MUTEMSGS` flag definitions
- `sys/kern/subr_boot.c` — maps `boot_mute` loader variable to `RB_MUTE`