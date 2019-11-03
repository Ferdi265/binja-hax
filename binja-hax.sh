#!/bin/bash

USAGE=$(cat <<END
usage: $0 [binaryninja arguments...]
enable different hacks by setting the corresponding environment variable to 1

Configuration
  BINJA_DIR ...... path to the binaryninja directory (writable)
  BINJA_HAX_DIR .. path to the binja-hax directory (writable)

Hacks
  BINJA_HAX_SYSTEM_LIBRARIES .. prefer loading libraries from /lib
                                (needed for wayland support)
  BINJA_HAX_SYSTEM_QT_CONF .... use system qt configuration and resources
                                (needed for wayland support)
  BINJA_HAX_FORCE_WAYLAND ..... force use of wayland
  BINJA_HAX_FORCE_X11 ......... force use of X11
  BINJA_HAX_QUIET ............. ignore binaryninja stderr
END
)

log() {
    echo "[BINJA_HAX]" "$@" >&2
}

binja() {
    exec "$BINJA_DIR/binaryninja" "$@"
}

FATAL=0

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "$USAGE"
    exit 0
fi

if [[ -z $BINJA_DIR || ! -d $BINJA_DIR || ! -x "$BINJA_DIR/binaryninja" ]]; then
    log "!!" "BINJA_DIR is not set or does not contain binaryninja executable"
    FATAL=1
fi

if [[ -z $BINJA_HAX_DIR || ! -d $BINJA_HAX_DIR || \
        ! -f "$BINJA_HAX_DIR/binja-hax.sh" ]]; then
    log "!!" "BINJA_HAX_DIR is not set or does not contain binja-hax.sh script"
    FATAL=1
fi

if [[ $FATAL -eq 1 ]]; then
    log "exiting..."
    exit 1
fi

if [[ ! -w "$BINJA_DIR/qt.conf" ]]; then
    log "!!" "cannot write to qt.conf in BINJA_DIR, SYSTEM_QT_CONF hack will" \
        "not work"
fi

if [[ ! -w "$BINJA_HAX_DIR/qt.orig.conf" ]]; then
    log "!!" "cannot write to qt.orig.conf in BINJA_HAX_DIR, automatic backup" \
        "of default qt.conf will not work"
fi

if [[ ! -w "$BINJA_DIR/.not_updated" ]]; then
    log "!!" "cannot write to .not_updated in BINJA_DIR, update detection" \
        "will not work"
elif [[ ! -f "$BINJA_DIR/.not_updated" ]]; then
    log "detected binaryninja update"

    if [[ -f "$BINJA_DIR/qt.conf" ]]; then
        log "backing up qt.conf as qt.orig.conf"
        cp "$BINJA_DIR/qt.conf" "$BINJA_HAX_DIR/qt.orig.conf"
    fi

    touch "$BINJA_DIR/.not_updated"
fi

if [[ ! -f "$BINJA_HAX_DIR/qt.orig.conf" ]]; then
    if [[ -f "$BINJA_DIR/qt.conf" ]]; then
        log "backing up qt.conf as qt.orig.conf"
        cp "$BINJA_DIR/qt.conf" "$BINJA_HAX_DIR/qt.orig.conf"
    else
        log "!!" "could not find qt.conf or qt.orig.conf!"
    fi
fi

if [[ $BINJA_HAX_SYSTEM_LIBRARIES -eq 1 ]]; then
    log "using system libraries"

    # workaround some weird symbol bug
    export LD_PRELOAD="$BINJA_DIR/libQt5Positioning.so.5"
    # load system libraries
    export LD_LIBRARY_PATH=/lib
fi

if [[ $BINJA_HAX_SYSTEM_QT_CONF -eq 1 ]]; then
    log "using system qt configuration"
    ln -sf "$BINJA_HAX_DIR/qt.system.conf" "$BINJA_DIR/qt.conf"
else
    log "using original qt configuration"
    ln -sf "$BINJA_HAX_DIR/qt.orig.conf" "$BINJA_DIR/qt.conf"
fi

if [[ $BINJA_HAX_FORCE_WAYLAND -eq 1 ]]; then
    log "forcing use of wayland"
    export QT_QPA_PLATFORM=wayland-egl
elif [[ $BINJA_HAX_FORCE_X11 -eq 1 ]]; then
    log "forcing use of x11"
    export QT_QPA_PLATFORM=xcb
fi

if [[ $BINJA_HAX_QUIET -eq 1 ]]; then
    log "launching binaryninja quietly"
    binja "$@" 2>/dev/null
else
    binja "$@"
fi
