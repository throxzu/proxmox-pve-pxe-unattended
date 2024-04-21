Setup:

- Download PVE iso from Proxmox (https://www.proxmox.com/en/downloads)
- Extract the folloing files using 7z or similar
  - \proxmox-ve_8.1-2.iso\boot\initrd.img\initrd
  - \proxmox-ve_8.1-2.iso\pve-installer.squashfs\usr\bin\proxinstall
  - \proxmox-ve_8.1-2.iso\pve-installer.squashfs\usr\share\perl5\Proxmox\Install\Config.pm
  - \proxmox-ve_8.1-2.iso\boot\initrd.img\initrd\init
- Copy all extracted files a build directory ex: /tmp/proxmox/build.
- Copy the proxmox-ve_8.1-2.iso to the build directory and rename it to proxmox.iso (Important)
- Rename initrd to initrd.org

  
Build directory should look like this:
```
[root@mgtsadepl01 build]# ls -l
total 1452188
-rwxr-xr-x. 1 root root        328 Apr 20 19:30 build.sh
-rw-r--r--. 1 root root       7340 Apr 21 08:08 Config.pm
-rwxrwxrwx. 1 root root      13297 Apr 20 19:40 init
-rw-r--r--. 1 root root  197218816 Apr 20 17:29 initrd.org
-rwxr-xr-x. 1 root root      50905 Apr 21 12:13 proxinstall
-rw-------. 1 root root 1289736192 Apr 20 19:02 proxmox.iso
[root@mgtsadepl01 build]#
```

Create the build.sh script
 ```
rm -f initrd.img
cp initrd.org initrd
echo proxmox.iso | cpio -L -H newc -o -O initrd -A
echo Config.pm | cpio -L -H newc -o -O initrd -A
echo proxinstall | cpio -L -H newc -o -O initrd -A
echo init | cpio -L -H newc -o -O initrd -A
gzip -9 initrd
mv initrd.gz initrd.img
```

Modifing files:
