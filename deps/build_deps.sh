#!/bin/sh

set -e

if [ "$1" = clean ] ; then
    if [ ! -z "$DEPS_BUILD_DIR" ] ; then
        rm -rf "$DEPS_BUILD_DIR"/*
    fi
    exit
fi

# Include Homebrew binaries on PATH if not there yet:
PATH="$PATH:/usr/local/bin"

# Fake Java binaries so that gettext configure script doesn't invoke the system ones:
mkdir -p "$DEPS_BUILD_DIR/helpers"
touch "$DEPS_BUILD_DIR"/helpers/{java,javac}
chmod +x "$DEPS_BUILD_DIR"/helpers/{java,javac}
PATH="$DEPS_BUILD_DIR/helpers:$PATH"

if [ -d /usr/local/opt/ccache/libexec ] ; then
    CC=/usr/local/opt/ccache/libexec/clang
    CXX=/usr/local/opt/ccache/libexec/clang++
else
    CC=clang
    CXX=clang++
fi

if [ "$CONFIGURATION" = "Debug" ] ; then
    cflags_config="-O2 -ggdb3"
    ldflags_config="-O2 -ggdb3"
else
    cflags_config="-O2"
    ldflags_config=""
fi

cat <<EOT >build.vars.local.ninja
# Generated by Xcode on `date`
SDKROOT = $SDKROOT
MACOSX_DEPLOYMENT_TARGET = $MACOSX_DEPLOYMENT_TARGET
CONFIGURATION = $CONFIGURATION

top_srcdir = `pwd`
builddir = $DEPS_BUILD_DIR

cc = $CC
cxx = $CXX

cflags_config = $cflags_config
ldflags_config = $ldflags_config
EOT

ninja
