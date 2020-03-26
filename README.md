# Z80 Crypto

A library of cryptographic routines for the Z80 processor.

## Preparation

```
zcc +rc2014 -subtype=cpm -clib=sdcc_iy -SO3 -v -m --list @bigmul.lst -o bigmul -create-app
zcc +rc2014 -subtype=cpm -clib=sdcc_iy -SO3 -v -m --list @secp256k1.lst -o secp256k1 -create-app
```
