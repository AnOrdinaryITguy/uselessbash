#!/bin/bash
NFS_SERVER="ENTER NFS SERVER IP"
ID=$(vcgencmd otp_dump | grep 28: | sed s/.*://g)
### Create root partition
mkdir /nfs
mkdir /nfs/root
#mount -t nfs $NFS_SERVER:/volume1/rpi-pxe /nfs/root
mount -t nfs -O proto=tcp,port=2049,rw,all_squash,anonuid=1001,anongid=1001 $NFS_SERVER:/volume1/rpi-pxe /nfs/root
mkdir /nfs/root/RPi4_$ID
rsync -xa --progress --exclude /nfs / /nfs/root/RPi4_$ID
# Edit fstab to mount NFS shares at boot
sed -i '2,$s/^.*$/#&/' /nfs/root/RPi4_$ID/etc/fstab
echo -e "$NFS_SERVER:/volume1/rpi-tftpboot/$ID\t/boot\tnfs\tdefaults\t0\t2" | tee -a /nfs/root/RPi4_$ID/etc/fstab
echo -e "$NFS_SERVER:/volume1/rpi-pxe/RPi4_$ID\t/\tnfs\tdefaults,noatime\t0\t1" | tee -a /nfs/root/RPi4_$ID/etc/fstab

### Create boot partition
mkdir /nfs/boot
mount -t nfs $NFS_SERVER:/volume1/rpi-tftpboot /nfs/boot
mkdir /nfs/boot/$ID
cp -r /boot/firmware/* /nfs/boot/$ID/
echo "console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=$NFS_SERVER:/volume1/rpi-pxe/RPi4_$ID rw ip=dhcp elevator=deadline rootwait cgroup_memory=1 cgroup_enable=memory" > /nfs/boot/$ID/cmdline.txt

echo "Script Finished"
