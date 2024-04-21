rm -f initrd.img
cp initrd.org initrd
echo proxmox.iso | cpio -L -H newc -o -O initrd -A
echo Config.pm | cpio -L -H newc -o -O initrd -A
echo proxinstall | cpio -L -H newc -o -O initrd -A
echo init | cpio -L -H newc -o -O initrd -A
gzip -9 initrd
mv initrd.gz initrd.img
#cp initrd.img /media/opsware/linux/Proxmox/ISO/pxeboot

