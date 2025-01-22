# Local Variables:
# mode: makefile
# End:
# vim: set ft=make :

linux_dir := justfile_directory() + "/../linux"
uroot_dir := justfile_directory() + "/../u-root"
linux_repo := "https://github.com/torvalds/linux"
uroot_repo := "https://github.com/u-root/u-root"

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

clone-uroot:
    #!/usr/bin/env bash
    if [[ ! -d {{ uroot_dir }} ]]; then
        git clone {{ uroot_repo }} {{ uroot_dir }}
    fi

install-linux: build-linux
    #!/usr/bin/env bash
    set -xeu
    rm -rf $(pwd)/{kernel,kernel-modules}
    export INSTALL_PATH=$(pwd)/kernel
    export INSTALL_MOD_PATH=$(pwd)/kernel-modules
    cd {{ linux_dir }}
    make -C {{ linux_dir }} -j$(nproc) modules_install
    make -C {{ linux_dir }} -j$(nproc) install

build-initrd: install-linux clone-uroot
    #!/usr/bin/env bash
    set -xeu
    initrd=$(pwd)/initramfs.cpio
    pushd {{ uroot_dir }}
    u-root -o $initrd -uinitcmd ""
    popd
    # append kernel modules to initrd
    cd $(pwd)/kernel-modules
    find . | cpio -H newc -o >> "$initrd"

nixos-image:


qemu: build-initrd
    qemu-kvm -nographic -kernel $(pwd)/kernel/vmlinuz -initrd $(pwd)/initramfs.cpio -append "console=ttyS0"
