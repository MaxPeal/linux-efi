#!/bin/bash

#parse all disks and 
if [ "$zerofree" != "ALL" ]; then
  echo "Are you sure to continue with compact the hard disks? (y/N)"
  read key
  case "$key" in
  y|Y|s|S)
    zerofree=ALL
  ;;
  esac
fi

[ "$zerofree" != "ALL" ] && exit
  
if [ -n "$(lspci | grep -i virtualbox)" ]; then

  for i in `ls /sys/class/block/ | egrep -i "sd|hd" | grep -v [0-9]`;
  do
#     echo "Umounting /dev/$i*"
    umount /dev/$i*

#   if it's completly umounted proceed
    if [ -z "$(cat /proc/self/mounts | grep -i /dev/$i)" ]; then
# 	echo "Umounted perfect $i. Removing Zeros from partition"
	for i in  `ls /dev/$i?*`
	do
    echo " * Executing ZeroFree to $i *"
	  echo 
# 	echo "Now passing FSCK to be sure that all is OK"
	  fs="$(blkid $i -c /dev/null -o value -s TYPE)"
	  [ "$fs" != "" -a "$fs" != "swap" ] && zerofree -v $i
	  [ "$fs" != ntfs -a "$fs" != "" -a "$fs" != "swap" ] && fsck.$fs $i
	done
	
    fi
  done  
  
    echo "Proces ended. Now you should stop virtual machine and compact the disk"
  echo
else
  #echo "Need to be executed on VirtualBox"
fi
