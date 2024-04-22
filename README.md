# proxmox-pve-pxe-unattended

Modify the installer for Proxmox PVE 8.1.2 to accept parameters to run unattened.

Limitations
- No software RAID setup
- My perl skills :-)

Extra kernel parameters:
 - px_dns=\<dns ip\>
 - px_domain=\<domain\>
 - px_cidr=\<server ip/subnet\>
 - px_gw=\<gateway ip\>
 - px_keymap=\<keyboard\>
 - px_time_zone=\<timezone\>
 - px_country=\<country code\>
 - px_hostname=\<hostname\>
 - px_mail=\<mail address\>
 - px_target_hd=\<hd\>
 - px_mngmt_nic=\<nic\>
 - px_mngmt_nic_id=\<nic id\>
 - px_password=\<root password\>
 - px_unattend=\<yes/no\>

 Example from grub.cfg
- linux   /boot/linux26 ro ramdisk_size=16777216 rw splash=verbose vga=788 px_dns=10.10.10.100 px_domain=mgmt.domain.com px_cidr=10.10.10.10/24 px_gw=10.10.10.1 px_keymap=dk px_time_zone=Europe/Copenhagen px_country=dk px_hostname=pv202 px_mail=no_reply@mailme.com px_target_hd=/dev/sda px_mngmt_nic=eno5np0 px_mngmt_nic_id=2 px_password=SuperSecret px_unattend=yes

Findings:
 - Using grubx64.efi from the Proxmox iso gave me an "out of memory" error when loading initrd so I used grubx64.efi from the latest Ubuntu distro.
  
  
