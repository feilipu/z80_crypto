# Z80 Crypto

A library of cryptographic routines for the Z80 processor.

## Preparation

```
zcc +rc2014 -subtype=cpm -SO3 -v -m --list @test/bigmul.lst -o bigmul -create-app
zcc +rc2014 -subtype=cpm -SO3 -v -m --list @test/secp256k1.lst -o secp256k1 -create-app
```