# Kernel development with NixOS userland

This repository shows how to get a kernel development environment running for NixOS including support for dynamic loaded kernel modules.
The example uses qemu but it should also work for bare-metal machines, assuming you have a bootloader or net-boot set up.

# Accessing the devshell

```
❯ nix develop
❯ just -l
Available recipes:
    build-initrd    # Build initrd bassed on busybox and kernel modules
    build-linux     # Build linux kernel
    clean-linux     # Clean build directory of linux
    clone-linux     # Git clone linux kernel
    configure-linux # Configure linux kernel build
    default         # Interactively select a task from just file
    install-linux   # Install linux kernel and kernel modules
    nixos-image     # Build nixos image
    qemu            # Boot in qemu
```

## Boot in qemu

```
❯ just qemu
```
