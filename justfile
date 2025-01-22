# Local Variables:
# mode: makefile
# End:
# vim: set ft=make :

linux_dir := justfile_directory() + "/../linux"
linux_repo := "https://github.com/torvalds/linux"

# Interactively select a task from just file
default:
    @just --choose

# Git clone linux kernel
clone-linux:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ ! -d {{ linux_dir }} ]]; then
      git clone {{ linux_repo }} {{ linux_dir }}
    fi

# Configure linux kernel build
configure-linux:
    #!/usr/bin/env bash
    set -xeuo pipefail
    if [[ ! -f {{ linux_dir }}/.config ]]; then
      cd {{ linux_dir }}
      make defconfig kvm_guest.config
      # This can be used for further customization
      # scripts/config \
      #   --disable DRM \
    fi

# Clean build directory of linux
clean-linux: configure-linux
    cd {{ linux_dir }} && make -C {{ linux_dir }} mrproper

# Build linux kernel
build-linux: configure-linux
    #!/usr/bin/env bash
    set -xeu
    cd {{ linux_dir }}
    yes "" | make -C {{ linux_dir }} -j$(nproc)

# Install linux kernel and kernel modules
install-linux: build-linux
    #!/usr/bin/env bash
    set -xeu
    export INSTALL_PATH=$(pwd)/kernel
    export INSTALL_MOD_PATH=$(pwd)/initrd
    cd {{ linux_dir }}
    make -C {{ linux_dir }} -j$(nproc) modules_install
    make -C {{ linux_dir }} -j$(nproc) install

# Build initrd bassed on busybox and kernel modules
build-initrd: install-linux
    #!/usr/bin/env bash
    set -xeu
    initrd=$(pwd)/initramfs.cpio
    stage1=$(pwd)/stage1.sh
    # append kernel modules to initrd
    cd $(pwd)/initrd
    mkdir -p bin sbin
    busybox --install -s bin/
    cp "$stage1" ./sbin/init
    find . | cpio -H newc -o > "$initrd"

# Build nixos image
nixos-image:
    [[ -f ./nixos-image/nixos.img ]] || nix build -o ./nixos-image ".#nixos-image"
    [[ -f ./nixos.img ]] || install -m600 ./nixos-image/nixos.img ./nixos.img

# Boot in qemu
qemu: build-initrd nixos-image
    qemu-kvm \
      -nographic -kernel $(pwd)/kernel/vmlinuz -initrd $(pwd)/initramfs.cpio -append "root=/dev/sda console=ttyS0,115200" \
       -m 1G -smp 2 -enable-kvm -cpu host -drive file=$(pwd)/nixos.img,format=raw
