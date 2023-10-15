esp-cross-sdk
-------------

This is fork of esp-open-sdk: https://github.com/pfalcon/esp-open-sdk

This repository provides the integration scripts to build a complete
standalone SDK (with toolchain) for software development with the
Espressif ESP8266 and ESP8266EX chips.

Requirements and Dependencies
-----------------------------

## macOS:

MacPorts packages installed:

sudo port install bash binutils coreutils automake wget gawk libtool help2man gperf gsed grep ncurses gettext esptool py-serial


Building
--------

make

License
-------

esp-cross-sdk is in its nature merely a makefile, and is in public domain.
However, the toolchain this makefile builds consists of many components,
each having its own license. You should study and abide them all.

Quick summary: gcc is under GPL, which means that if you're distributing
a toolchain binary you must be ready to provide complete toolchain sources
on the first request.

Since version 1.1.0, vendor SDK comes under modified MIT license. Newlib,
used as C library comes with variety of BSD-like licenses. libgcc, compiler
support library, comes with a linking exception. All the above means that
for applications compiled with this toolchain, there are no specific
requirements regarding source availability of the application or toolchain.
(In other words, you can use it to build closed-source applications).
(There're however standard attribution requirements - see licences for
details).
