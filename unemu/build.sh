#!/usr/bin/env bash
# This file may be distributed under the terms of the GNU LGPLv3 license.
#
# Rebuild the two ROMs of the unemu release from this source tree alone:
# the ISA SeaBIOS (out of unemu/config) and the standard-VGA SeaVGABIOS (out of
# unemu/vgaconfig). Run from the top of an extracted release archive:
#     bash unemu/build.sh <output directory>
# Needs an i686-elf GCC and binutils (CROSS_PREFIX, default i686-elf-), a host
# C compiler (HOSTCC, default cc), Python 3, GNU make, tar and a SHA-256 tool.
# See unemu/BUILD.md for the toolchain the published ROMs were built with.
set -euo pipefail
export LC_ALL=C

OUT_DIR="${1:?usage: unemu/build.sh <output directory>}"
CROSS_PREFIX="${CROSS_PREFIX:-i686-elf-}"
HOSTCC="${HOSTCC:-cc}"
VERSION="1.17.0"
BIOS_SHA256="ad50fdb5e12a03dd5c17eac481a4183a7793b84252319eea02b8c878667c994f"
VGA_SHA256="1adc6c0fa72b93c5d0659575c992b1bf6f64fd451c444b2a735e22f0a3d6e925"

if command -v sha256sum >/dev/null 2>&1; then
	SHA256=(sha256sum)
else
	SHA256=(shasum -a 256)
fi

TOP="$(pwd)"
[ -f "$TOP/unemu/config" ] && [ -f "$TOP/Makefile" ] || {
	echo "run from the top of the source tree" >&2
	exit 1
}
mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Build each ROM in its own copy of the tree, without the unemu/ directory.
build() {
	local name="$1" config="$2" extraversion="$3" target="$4" product="$5" expected="$6"
	local tree="$WORK/$name"
	mkdir "$tree"
	tar -C "$TOP" --exclude=./unemu -cf - . | tar -C "$tree" -xf -
	cp "$TOP/unemu/$config" "$tree/.config"
	# A .version file plus a nonempty suffix keeps the build time and host
	# name out of the version string, so the bytes are reproducible.
	printf '%s\n' "$VERSION" > "$tree/.version"
	local args=(-C "$tree" "CROSS_PREFIX=$CROSS_PREFIX" "HOSTCC=$HOSTCC"
		"CPP=${CROSS_PREFIX}cpp" PYTHON=python3 "EXTRAVERSION=$extraversion")
	make "${args[@]}" olddefconfig
	make "${args[@]}" $target
	cp "$tree/out/$product" "$OUT_DIR/$name"
	local actual
	actual="$("${SHA256[@]}" "$OUT_DIR/$name" | awk '{print $1}')"
	if [ "$actual" != "$expected" ]; then
		echo "$name: SHA-256 $actual differs from the published $expected" >&2
		exit 1
	fi
	echo "built $OUT_DIR/$name ($actual)"
}

build seabios-isa.bin config -unemupc98-isa "" bios.bin "$BIOS_SHA256"
build seavgabios-stdvga.bin vgaconfig -unemupc-stdvga out/vgabios.bin vgabios.bin "$VGA_SHA256"
