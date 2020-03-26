# Z80 Crypto

A library of cryptographic routines for the Z80 processor.

## Preparation

```
zcc +rc2014 -subtype=cpm -clib=sdcc_iy -SO3 -v -m --list --max-allocs-per-node100000 @bigmul.lst -o bigmul -create-app
```
