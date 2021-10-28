# binja-hax

A collection of hacky tweaks for [binaryninja](https://binary.ninja) (wayland
support, system Qt libs)

## Usage

```
usage: binja-hax.sh [binaryninja arguments...]
enable different hacks by setting the corresponding environment variable to 1

Configuration
  BINJA_DIR ...... path to the binaryninja directory (writable)
  BINJA_HAX_DIR .. path to the binja-hax directory (writable)

Hacks
  BINJA_HAX_SYSTEM_LIBRARIES .. prefer loading libraries from /lib
                                (needed for wayland support)
  BINJA_HAX_SYMVER_FIX ........ preload shared object to fix symbol versions
                                (obsolete, but left in if needed in the future)
  BINJA_HAX_SYSTEM_QT_CONF .... use system qt configuration and resources
                                (needed for wayland support)
  BINJA_HAX_FORCE_WAYLAND ..... force use of wayland
  BINJA_HAX_FORCE_X11 ......... force use of X11
  BINJA_HAX_QUIET ............. ignore binaryninja stderr
```

## Linux Distribution Support

I have only tested this script on [ArchLinux](https://archlinux.org). Library
paths or preloaded libraries might need to be different on other distributions,
or it might not work at all.

## Installation

1. Clone this repository or copy its files into a directory you want to install
   to.
2. export `BINJA_DIR` to point to the binaryninja installation directory
3. export `BINJA_HAX_DIR` to point to the directory you installed this
   repository to
4. put `binja-hax.sh` somewhere in your `PATH`
5. if you intend to use `BINJA_HAX_SYMVER_FIX`, run `make` once in the
   `symver_fix/` directory

For some of the hacks to work, the `BINJA_DIR` and `BINJA_HAX_DIR` directories
need to be writable.

**Note:** don't install directly into the binaryninja directory, it will be
overwritten whenever binaryninja updates.

## Binaryninja Updates

When updating, binaryninja replaces the `qt.conf` with the new, updated version.

This means that when using the `SYSTEM_LIBRARIES`, `SYSTEM_QT_CONF`, or
`FORCE_WAYLAND` hacks, binaryninja might not start the first time after
updating.

When running `binja-hax.sh` a second time after that, it should correctly
identify binaryninja has updated and start up successfully.

## System Libraries and Qt Versions

The `SYSTEM_LIBRARIES` hack only works if the systems installed Qt libraries
are compatible with the ones binaryninja is linked to. Since the port to Qt6,
this can often not be the case, especially after system updates (if the system
updates sooner than binaryninja) or binaryninja (if binaryninja updates sooner
than the system).

Previously, binaryninja linked to symbols with incorrect symbol versions in the
provided Qt libraries (C++ STL functions with a Qt5 symbol version). For this,
the `SYMVER_FIX` hack was created to redirect those functions to the correct
ones. Since the Qt6 port, this hack is no longer needed.

## Wayland Support

The quickest way to provide wayland support for binaryninja is to use these
hacks:

- `BINJA_HAX_SYSTEM_LIBRARIES`
- `BINJA_HAX_SYSTEM_QT_CONF`
- `BINJA_HAX_FORCE_WAYLAND` (if wayland is not already default)
