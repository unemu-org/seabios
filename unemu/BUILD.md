# Building the unemu release ROMs

Release `v1.17.0-unemu1` publishes two ROMs built from this tree:

| Asset | Size | SHA-256 | Configuration | Version string |
|---|---|---|---|---|
| `seabios-isa.bin` | 131072 | `ad50fdb5e12a03dd5c17eac481a4183a7793b84252319eea02b8c878667c994f` | `unemu/config` | `1.17.0-unemupc98-isa` |
| `seavgabios-stdvga.bin` | 32768 | `1adc6c0fa72b93c5d0659575c992b1bf6f64fd451c444b2a735e22f0a3d6e925` | `unemu/vgaconfig` | `1.17.0-unemupc-stdvga` |

`seabios-isa.bin` is SeaBIOS for QEMU-style firmware on an ISA board without
PCI (fw_cfg, serial console on COM1, debug console at port 402h, floppy and
ISA ATA boot). `seavgabios-stdvga.bin` is SeaVGABIOS for a standard VGA with no
PCI ROM header and no VBE.

To rebuild both from the release source archive, extract it and run, from the
top of the tree:

    bash unemu/build.sh <output directory>

The script builds each ROM in a clean copy of the tree (without `unemu/`),
with a fixed version string, and checks the SHA-256 values above.

The published ROMs were built with i686-elf GCC 15.2.0 and GNU binutils 2.46
from nixpkgs (the `firmware` development shell of
<https://github.com/unemu-org/unemupc>, `vendor/seabios/fetch.sh`), on
macOS arm64; two independent builds were byte-identical. Other compiler
versions may produce different bytes.
