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
- Edit the **init** file using vi or your favorite editor and locate the lines

  ```
    cp /etc/hostid /mnt/.installer-mp/etc/
    cp /.cd-info /mnt/.installer-mp/ || true
  ```
  Append these 2 extra lines above and save the file

  ```
    cp /proxinstall /mnt/.installer-mp/usr/bin/
    cp /Config.pm /mnt/.installer-mp/usr/share/perl5/Proxmox/Install

    cp /etc/hostid /mnt/.installer-mp/etc/
    cp /.cd-info /mnt/.installer-mp/ || true
  ```

- Edit the **Config.pm** file and locate the lines in **sub parse_kernel_cmdline**
  ```
    my $iso_env = Proxmox::Install::ISOEnv::get();
    if ($iso_env->{product} eq 'pve') {
        if ($cmdline =~ s/\bmaxvz=(\d+(\.\d+)?)\s?//i) {
            $cfg->{maxvz} = $1;
        }
    }
  ```
   Append the following section above these lines
  ```
   # Mod for unattended pxe boot
    if ($cmdline =~ s/\bpx_dns=(\S+)//i) {
        $cfg->{dns} = $1;
    }
    if ($cmdline =~ s/\bpx_domain=(\S+)//i) {
        $cfg->{domain} = $1;
    }
    if ($cmdline =~ s/\bpx_cidr=(\S+)//i) {
        $cfg->{cidr} = $1;
    }
    if ($cmdline =~ s/\bpx_gw=(\S+)//i) {
        $cfg->{gateway} = $1;
    }
    if ($cmdline =~ s/\bpx_keymap=(\S+)//i) {
        $cfg->{keymap} = $1;
    }
    if ($cmdline =~ s/\bpx_time_zone=(\S+)//i) {
        $cfg->{timezone} = $1;
    }
    if ($cmdline =~ s/\bpx_country=(\S+)//i) {
        $cfg->{country} = $1;
    }
    if ($cmdline =~ s/\bpx_hostname=(\S+)//i) {
        $cfg->{hostname} = $1;
    }
    if ($cmdline =~ s/\bpx_mail=(\S+)//i) {
        $cfg->{mailto} = $1;
    }
    if ($cmdline =~ s/\bpx_target_hd=(\S+)//i) {
        $cfg->{target_hd} = $1;
    }
    if ($cmdline =~ s/\bpx_mngmt_nic=(\S+)//i) {
        $cfg->{mngmt_nic} = $1;
    }
    if ($cmdline =~ s/\bpx_mngmt_nic_id=(\S+)//i) {
        $cfg->{mngmt_nic_id} = $1;
    }
    if ($cmdline =~ s/\bpx_password=(\S+)//i) {
        $cfg->{password} = $1;
    }

    if ($cmdline =~ s/\bpx_unattend=(\S+)//i) {
        $cfg->{unattend} = $1;
    }
    #end mod
  ```
  Locate the **sub set_key** subrotine
  ```
  sub set_key {
    my ($k, $v) = @_;
    my $cfg = get();
    croak "unknown key '$k'" if !exists($cfg->{$k});
    $cfg->{$k} = $v;
  }
  ```
  And append the following to lines below so it look like this
  ```
  sub set_key {
    my ($k, $v) = @_;
    my $cfg = get();
    croak "unknown key '$k'" if !exists($cfg->{$k});
    $cfg->{$k} = $v;
  }

  # Mod for unattend Proxmox
  sub set_unattend { set_key('unattend', $_[0]); }
  sub get_unattend { return get('unattend'); }
  # End Mod
  ```
  Save **Config.pm**

- Edit **proxinstall** and locate the line in subrutine **sub create_ack_view**
  
   ```
       my $country = Proxmox::Install::Config::get_country();
   ```
   Append the following line below
  ```
  # Mod for unattend
    my $unattend = Proxmox::Install::Config::get_unattend();
    my $hd = "";

    if ($unattend eq "yes") {
        $hd = Proxmox::Install::Config::get_target_hd();
    } else {
        $hd = join(' | ', $target_hds->@*);
    }
    # End Mod
  ```
  Update **__target_hd__** line in
  ```
   my %config_values
  ```
  to read
  ```
   __target_hd__ => $hd,
  ```

  Goto the end of the **proxinstall** file and replace the

  ```
  create_intro_view () if !$initial_error;
  ```
  With
  ```
  my $unattend = Proxmox::Install::Config::get_unattend();
  if ($unattend eq "yes") {
  create_extract_view();
  } else {
  create_intro_view () if !$initial_error;
  }
  ```
  Save the **proxinstall** file

- Run ./build.sh and a custom **initrd.img** should now be ready for you pxe boot server.
  
   
  

  

