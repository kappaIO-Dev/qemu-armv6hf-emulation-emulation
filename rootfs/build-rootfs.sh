#!/bin/sh
# Part of spindle http://asbradbury.org/projects/spindle
#
# See LICENSE file for copyright and license details

set -ex
# Security for these keys doesn't matter: just using ssh as it's convenient 
# It's not easy to disable authentication, so just use passwordless keys.

# could be generated with dropbearkey -t dss -f 
# ./etc/dropbear/dropbear_dss_host_key and base64 encoding the result
DROPBEAR_DSS_KEY=$(cat <<EOF
AAAAB3NzaC1kc3MAAACBANfidOdFkDa7co3actgF4sQ0R8sYTzQ5jLAx23nwy5HKDt5pzwXKnkjq
wBm7/CsC7/WHozTlRSIwA+9jlZlteOUzALTUkICVA24rg90gjqiR5Gzqd6nSB1iKWjbTX5rxR+9j
HcVzfp832HHTRJgthQ035Em+6lJJ4PpIgRhDDE2jAAAAFQDlWsVzKm4G24GQnGxDuhGsrC2i5wAA
AIBelNlG6om0WZYsP9M1kA9DCaWaWVLVt/o7AeSjTT1/f7E2xwluPBRLqKMYdWab4EdkoZLL9QU/
c4t6vRSYMZ8dxT8fpZ49HZLMrg6Defxb5Us6IaMGJwEXKx5s1p37S2SMs2oYLBAxtTv3a2WvVGxO
mTFe6O1QV8C2/0Mml92S5wAAAIEAtaxaCnAIu1FJ4GJLAoKDQA2OZElYgMoD6WGn1JMYjdKa3xE0
8pl/IBt+OTZ3TR8ifuB0NrS6jlSi6pZVeqauZyZIkiIJPBULcsXWm98meeQpi0sz+uVyGSxVcVGT
icg5BSkoPHjAC4KrojvTKR85PPgW1rMeJ3sGgtSXsTVMEVQAAAAVALRiKgnxo7cCasEP41n3Kd3n
/5PB
EOF
)

# could be generated with sh-keygen -t dsa -f qemu_arm_key -N ""
PRIVATE_SSH_KEY=$(cat <<EOF
-----BEGIN DSA PRIVATE KEY-----
MIIBvAIBAAKBgQCndCU8k4fuxWa2phVz9s2WH2OtwYuNxn3I7VfW9WZt+La3DaKg
cjJo2yxT+PWbicdzZ7+bKn50F/9SJd+RgzcCrSHszOewpmDJfJQHrVje5A3XgfBF
3DZZzsRS3b4bR+24z7ws++qSL0UdQhX9R8V2UUPEw0B3tDZMsEB6os2D4wIVAP0K
CXSFvoyrSkxOV9SfLHY/wPbxAoGBAJa08pbR+BYR/5t6M2QMN+Hj87eReJ4Gov+j
ZGPFhVpQ7gdKllRMzWIxgb7UkxfXzXUhZSJHWOF66eFAP+zjEwiALYJVIcWCd19y
E3dP7qB9VTQdNYGrW0DA4oaxBL1AmnPtbrfT8mPs48dKoMoKYocoBYYASmu/hKU0
JTF5qtjTAoGAXHA/KTiu/w/e0LjX9aeMLu4+U9o+8AcRKKFUVsu2ADmrHTzPFE1F
0iBERYkCnm+n4ilOdL+YQTStyNzbsj8lgsc+PRB5f3S2o+Cd4ADC8E+A+FYrmYPK
duaZG6byxosiuE0SFPSnXtFHyw8uRH6ZFe/Z2qbdevgFO6ZU1kcvM4UCFQDnvfA8
2jtIk4Lc55jgJBl2ygLvwg==
-----END DSA PRIVATE KEY-----
EOF
)

# could be generated with sh-keygen -t dsa -f qemu_arm_key -N ""
PUBLIC_SSH_KEY="ssh-dss \
AAAAB3NzaC1kc3MAAACBAKd0JTyTh+7FZramFXP2zZYfY63Bi43GfcjtV9b1Zm34\
trcNoqByMmjbLFP49ZuJx3Nnv5sqfnQX/1Il35GDNwKtIezM57CmYMl8lAetWN7k\
DdeB8EXcNlnOxFLdvhtH7bjPvCz76pIvRR1CFf1HxXZRQ8TDQHe0NkywQHqizYPj\
AAAAFQD9Cgl0hb6Mq0pMTlfUnyx2P8D28QAAAIEAlrTyltH4FhH/m3ozZAw34ePz\
t5F4ngai/6NkY8WFWlDuB0qWVEzNYjGBvtSTF9fNdSFlIkdY4Xrp4UA/7OMTCIAt\
glUhxYJ3X3ITd0/uoH1VNB01gatbQMDihrEEvUCac+1ut9PyY+zjx0qgygpihygF\
hgBKa7+EpTQlMXmq2NMAAACAXHA/KTiu/w/e0LjX9aeMLu4+U9o+8AcRKKFUVsu2\
ADmrHTzPFE1F0iBERYkCnm+n4ilOdL+YQTStyNzbsj8lgsc+PRB5f3S2o+Cd4ADC\
8E+A+FYrmYPKduaZG6byxosiuE0SFPSnXtFHyw8uRH6ZFe/Z2qbdevgFO6ZU1kcv\
M4U= asb@ulala"

setup_dropbear() {
  chmod +x dropbearmulti-armv6l &&
  cp -a dropbearmulti-armv6l qemu_rootfs/bin/dropbear &&
  cd qemu_rootfs/bin &&
  ln -s dropbear scp &&
  cd "$OLDPWD" &&
  mkdir -p qemu_rootfs/etc/dropbear &&
  printf "%s" "$DROPBEAR_DSS_KEY" | base64 -d > qemu_rootfs/etc/dropbear/dropbear_dss_host_key &&
  printf "%s" "$PRIVATE_SSH_KEY" > qemu_arm_key &&
  chmod 600 qemu_arm_key &&
  printf "%s" "$PUBLIC_SSH_KEY" > qemu_arm_key.pub &&
  cp -a qemu_arm_key.pub qemu_rootfs/root
}

INIT_SH=$(cat <<\EOF
#!/bin/hush

# Announce version
sed -n 's/PRETTY_NAME="\([^"]*\)"/\1/p' /etc/os-release

export HOME=/home/root
export PATH=/bin:/sbin

# Mount filesystems
mountpoint -q proc || mount -t proc proc proc
mountpoint -q sys || mount -t sysfs sys sys
mountpoint -q dev || mount -t devtmpfs dev dev || mdev -s
mkdir -p dev/pts
mountpoint -q dev/pts || mount -t devpts dev/pts dev/pts
# /tmp inherited from initmpfs

# If nobody said how many CPUS to use in builds, try to figure it out.
if [ -z "$CPUS" ]
then
  export CPUS=$(echo /sys/devices/system/cpu/cpu[0-9]* | wc -w)
  [ "$CPUS" -lt 1 ] && CPUS=1
fi
export PS1="($HOST:$CPUS) \w \$ "

# Setup networking for QEMU (needs /proc)
ifconfig eth0 10.0.2.15
route add default gw 10.0.2.2

# If we have no RTC, try rdate instead:
[ "$(date +%s)" -lt 1000 ] && rdate 10.0.2.2 # or time-b.nist.gov

mount -t tmpfs /tmp /tmp
mount -t tmpfs /home /home
mount -t tmpfs /var /var
[ -b /dev/sdb2 ] && mount -o noatime /dev/sdb2 /mnt
[ -d /mnt/tmp ] && mount --bind /tmp /mnt/tmp

mkdir -p /home/root
cd $HOME
mkdir -p /home/root/.ssh
cp -a /root/qemu_arm_key.pub /home/root/.ssh/authorized_keys
chmod 600 /home/root/.ssh/authorized_keys

[ -z "$CONSOLE" ] &&
CONSOLE="$(sed -n 's@.* console=\(/dev/\)*\([^ ]*\).*@\2@p' /proc/cmdline)"

CONSOLE=ttyAMA0
dropbear -E -s
exec /sbin/oneit -c /dev/"$CONSOLE" /bin/sh
EOF
)

replace_init_sh() {
  printf "%s" "$INIT_SH" > qemu_rootfs/sbin/init.sh
}

make_var() {
  mkdir qemu_rootfs/var
}
if [ ! -d ./aboriginal-1.4.5/build/root-filesystem-armv6l ]
then
  cd aboriginal-1.4.5
  sudo ./build.sh armv6l
  sudo chown $USER:$USER build
  cd ..
fi
[ -d work ] && rm -rf work
mkdir work 
cp dropbearmulti-armv6l work
cd work
[ -d qemu_rootfs ] && rm -rf qemu_rootfs
cp -r ../aboriginal-1.4.5/build/root-filesystem-armv6l ./qemu_rootfs
setup_dropbear
replace_init_sh
make_var
mksquashfs qemu_rootfs qemu_rootfs.sqf -noappend -all-root
[ ! -z "$OUTDIR" ] && mv qemu_rootfs.sqf qemu_arm_key $OUTDIR
