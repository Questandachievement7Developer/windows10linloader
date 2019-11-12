#!/bin/bash
MemoryTotal=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
Memoryset=$(( ( $MemoryTotal / 2 ) / 1024 ))
memory="${Memoryset}M"
core=16
corehalve=$(( $core / 2 ))


image=sys.img
if [ ! -f $image ] ; then
qemu-img create -f qcow2 $image 32G
fi
# qemu-img create -f qcow2 mac_hdd_ng.img 128G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)
#echo 1 > /sys/module/kvm/parameters/ignore_msrs
#virsh net-autostart default
#sudo ip tuntap add dev tap0 mode tap
#sudo ip link set tap0 up promisc on
#sudo ip link set dev virbr0 up
#sudo ip link set dev tap0 master virbr0
############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

# This works for High Sierra as well as Mojave. Tested with macOS 10.13.6 and macOS 10.14.4.
MY_OPTIONS="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# OVMF=./firmware
OVMF="./"

qemu-system-x86_64 -enable-kvm -m ${Memoryset} -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$MY_OPTIONS\
	  -machine q35 \
	  -smp ${core},cores=${corehalves} \
	  -cdrom win10.iso \
	  -usb -device usb-kbd -device usb-tablet \
	  -drive if=pflash,format=raw,readonly,file=$OVMF/OVMF_CODE.fd \
	  -drive if=pflash,format=raw,file=$OVMF/OVMF_VARS.fd \
	  -smbios type=2 \
	  -device ich9-intel-hda -device hda-duplex \
	  -device ich9-ahci,id=sata \
	  -drive id=PCHDD,if=none,cache=unsafe,file=$image,format=qcow2 \
	  -device ide-hd,bus=sata.4,drive=PCHDD \
	  -net user \
	  -monitor stdio \
	  -device virtio-vga,virgl=on \
	  -vga virtio \
          -full-screen
