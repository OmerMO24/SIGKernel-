# Kernel for the second bitsig session 

## What you'll need:
  - QEMU: a machine emulator/virtualizer that we'll use to actually boot into our kernel.
  - Clang: a C compiler that is natively supports cross compilation
  - GNU Make (aka make): build tool, not explicitly necessary but makes rebuilding all the source files much easier
  - grub2: a bootloader (you need to install xorriso or libisoburn as well for this to work)
  - ld: a linker
  - NASM: a friendly assembler

## Platform specific installation stuff:
  - Windows: I have no idea tbh
  - macOS: I'm pretty sure macOS comes pre installed with Clang, Make, and ld. You can grab grub off of brew, the package is called x86_64-elf-grub
  - Linux: If you're on linux then you most probably know how to install all of this. Just use your package manager

Once you have everything installed, clone the repo and run make. If all goes well it should produce a file called albert.iso. You can then boot into the OS by running:

```console
qemu-system-x86_64 -cdrom albert.iso
```
You should see OKAY printed (yes it is supposed to have a green background). 

## What we're going to do 

- Currently, OKAY is being written straight to the memory mapped VGA buffer at 0xb8000. This is okay for testing purposes but we'd like to use C to print stuff to the terminal. We are in 2025 and writing assembly is out of fashion.
- The kernel.c file has some definitions that we don't understand quite yet, but that is fine, we'll go through them.
- There are also horrors in the boot.s file, thankfully WE ALL attended the bitsig assembly lesson last week and felt inspired enough to go home and do some extra reading. That knowledge should come in handy.

  
