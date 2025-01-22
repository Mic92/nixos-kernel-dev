#!/bin/sh

set -e

export PATH="/bin"

mkdir -m 0755 -p /proc /sys /dev /run
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mkdir -m 0755 -p /dev/pts
mount -t devpts none /dev/pts
mount -t tmpfs none /run

echo /bin/modprobe > /proc/sys/kernel/modprobe

for param in $(cat /proc/cmdline); do
 case $param in
 root=*) root=${param#root=} ;;
 esac
done

if [ -z "$root" ]; then
 echo "No root= parameter found in kernel command line. Aborting..."
 exit 1
fi

mnt=/mnt/rootfs
mkdir -m 0755 -p $mnt
while [ ! -e "$root" ]; do
 echo "Waiting for $root to appear..."
 sleep 1
done
mount "$root" $mnt
mkdir -m 0755 -p $mnt/proc $mnt/sys $mnt/dev $mnt/run

exec switch_root "$mnt" /sbin/init
