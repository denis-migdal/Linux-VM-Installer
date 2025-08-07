#!/usr/bin/bash

DECL () {
  if [ ! -v $1 ] ; then
    declare -g $1="$2"
  fi
}

DECL VM_USER  "Zeus"
DECL VM_LOGIN "zeus"
DECL VM_PWD   "1234"
#
DECL VM_HOSTNAME "LVMI"
DECL VM_DOMAIN   "$VM_HOSTNAME.localhost"
#
DECL VM_LOCALE   "fr_FR"
DECL VM_KEYBOARD "fr"
DECL VM_TZ       "Europe/Paris"
#
DECL VM_MIRROR     "mirror.dsi.uca.fr"
DECL VM_MIRROR_DIR "/debian/debian/"
DECL VM_PROXY      "$http_proxy"

# Generate file

d-i() { echo d_i $@ ; }
keyboard-configuration() { echo keyboard-configuration $@ ; }
taskel() { echo taskel $@ ; }

# Locale
d-i debian-installer/locale string "$VM_LOCALE"

d-i console-setup/ask_detect boolean false
d-i console-setup/layoutcode string "$VM_KEYBOARD"
d-i keyboard-configuration/xkb-keymap select "$VM_KEYBOARD(latin9)"
d-i keyboard-configuration/layoutcode string "$VM_KEYBOARD"
keyboard-configuration	keyboard-configuration/layoutcode	string	"$VM_KEYBOARD"

### Partitioning
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-basicfilesystems/no_swap boolean false
#d-i partman-auto/choose_recipe select atomic
d-i partman-auto/expert_recipe string noswap :: \
    1 1 1 free \
        \$iflabel{ gpt } \
        \$reusemethod{ } \
        method{ biosgrub } . \
    1000 8850 -1 \$default_filesystem \
        \$lvmok{ } \
        method{ format } \
        format{ } \
        use_filesystem{ } \
        \$default_filesystem{ } \
        mountpoint{ / } . \

d-i partman-auto/choose_recipe select noswap

# Network
d-i netcfg/get_hostname string "$VM_HOSTNAME"
d-i netcfg/get_domain string "$VM_DOMAIN"

d-i netcfg/choose_interface select auto
d-i netcfg/link_wait_timeout string 10

# Clock

#IF not VBOX ?
cat <<- EOF
@@VBOX_COND_IS_RTC_USING_UTC@@
d-i clock-setup/utc-auto boolean true
d-i clock-setup/utc boolean true
@@VBOX_COND_END@@
@@VBOX_COND_IS_NOT_RTC_USING_UTC@@
d-i clock-setup/utc-auto boolean false
d-i clock-setup/utc boolean false
@@VBOX_COND_END@@
EOF

d-i time/zone string "$VM_TZ"

#IF VBOX
echo "@@VBOX_COND_IS_INSTALLING_ADDITIONS@@d-i clock-setup/ntp boolean false@@VBOX_COND_END@@"
echo "@@VBOX_COND_IS_NOT_INSTALLING_ADDITIONS@@d-i clock-setup/ntp boolean true@@VBOX_COND_END@@"

# Packages, Mirrors, Image
d-i base-installer/kernel/override-image string linux-server
d-i base-installer/kernel/override-image string linux-image-amd64

d-i mirror/protocol string http
d-i mirror/country string manual
d-i mirror/http/country string manual
d-i mirror/mirror select "$VM_MIRROR"
d-i mirror/http/mirror select "$VM_MIRROR"
d-i mirror/hostname string "$VM_MIRROR"
d-i mirror/http/hostname string "$VM_MIRROR"
d-i mirror/directory string "$VM_MIRROR_DIR"
d-i mirror/http/directory string "$VM_MIRROR_DIR"
d-i mirror/proxy string "$VM_PROXY"
d-i mirror/http/proxy string "$VM_PROXY"

d-i mirror/suite string bookworm

# X

d-i apt-setup/disable-cdrom-entries boolean true
d-i apt-setup/use_mirror boolean true
d-i apt-setup/no_mirror boolean false

d-i pkgsel/install-language-support boolean false

taskel tasksel/first multiselect standard

# paquets supplémentaires
d-i pkgsel/include string openssh-server
d-i pkgsel/upgrade select none

# Users
d-i passwd/root-login boolean true
d-i passwd/root-password password "$VM_PWD"
d-i passwd/root-password-again password "$VM_PWD"
d-i passwd/user-fullname string "$VM_USER"
d-i passwd/username string "$VM_LOGIN"
d-i passwd/user-password password "$VM_PWD"
d-i passwd/user-password-again password "$VM_PWD"
d-i user-setup/allow-password-weak boolean true
d-i passwd/user-default-groups string admin

# This makes partman automatically partition without confirmation
d-i partman-partitioning/default_label string gpt
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Grub
d-i grub-installer/grub2_instead_of_grub_legacy boolean true
d-i grub-installer/only_debian boolean true

# Due notably to potential USB sticks, the location of the MBR can not be
# determined safely in general, so this needs to be specified:
#d-i grub-installer/bootdev  string /dev/sda
# To install to the first device (assuming it is not a USB stick):
d-i grub-installer/bootdev  string default

d-i finish-install/reboot_in_progress note
#d-i debian-installer/exit/poweroff boolean true

# Custom Commands.
# Note! Debian netboot images use busybox, so no bash.
#       Tell script to use target bash.
d-i preseed/late_command string "cp /cdrom/vboxpostinstall.sh /target/root/vboxpostinstall.sh \
 && chmod +x /target/root/vboxpostinstall.sh \
 && /bin/sh /target/root/vboxpostinstall.sh --need-target-bash --preseed-late-command"