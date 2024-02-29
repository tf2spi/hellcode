# hellcode

Have you ever wanted to be 1337 and c001 to all your friends by writing position-independ
shellcode not in assembly, but in your favorite systems level language like ``rust``, ``zig``
or ``c(++)``? Well, now you can with ``hellcode``!

``hellcode`` is a set of questionable, but functional, linker scripts and self-dynamic-linking
code written in ``zig`` for writing shellcode in high-level languages.

## Building

At the moment, no build script is used so you have to manually build all the objects.
That's a TODO.

```
zig build-obj -fPIC -target x86-freestanding -O ReleaseSmall bootstrapper.zig
zig build-obj -fPIC -target x86-freestanding -O ReleaseSmall test.zig
gcc -m32 -Wl,--build-id=none -fPIC -nostdlib -T arch/i386/shellcode.ld arch/i386/start.S bootstrapper.o test.o
rm *.o
```

I've tried using ``zig cc`` as well, but ``clang`` really doesn't like the hacks
being done here whereas ``gcc`` will happily comply.

This produces an ``elf`` file but because it is position independent,
``objcopy`` can be used to produce actual shellcode.

```
objcopy -O binary a.out a.bin
```
