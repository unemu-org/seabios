# SeaBIOS for the unemu emulators

This repository is a fork of [SeaBIOS](https://www.seabios.org)
(upstream: <https://github.com/coreboot/seabios>), kept for the unemu
emulators' period PC machines. The branch `main` is an upstream release
plus the fixes listed below; nothing else is changed.

Base: upstream `rel-1.17.0` (`b52ca86e094d19b58e2304417787e96b940e39c6`).

## Fixes on top of upstream

- `byteorder: avoid bswap so SeaBIOS runs on an 80386` — `__swab32()`
  used the `bswapl` instruction, which the 80386 lacks. It is reached from
  the QEMU fw_cfg code and from the ATA and block command code, so a build
  stopped with an invalid opcode on a real 386. The swap is now computed in
  C; with `-march=i386` gcc does not emit `bswap` for it. Intended for
  upstream submission.

## Building

The unemu PC emulator builds this source reproducibly with its own
configuration (`vendor/seabios/fetch.sh` and `vendor/seabios/config` in
<https://github.com/unemu-org/unemupc>). The upstream build instructions in
`README` apply unchanged.

## Licence

SeaBIOS is licensed under the GNU LGPLv3; see `COPYING.LESSER`. The fixes in
this fork are under the same licence.
