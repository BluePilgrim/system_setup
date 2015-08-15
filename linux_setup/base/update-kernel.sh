# this automates the build and install of linux kernel and necessary kernel_modules(r8168 this time).
#!/bin/bash
pushd /usr/src/linux
make && make modules_install
mount /dev/sda /boot
make install
rm -f /boot/*.old
cp /boot/vmlinuz-4.0.5-gentoo-by_david /boot/EFI/boot/bootx64.efi
emerge -a n net-misc/r8168
umount /boot
popd
