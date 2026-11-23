#!/usr/bin/env bash

iso_name="helix"
iso_label="HELIX_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Helix Linux <https://github.com/archlatam>"
iso_application="Helix Linux Live/Install"
iso_version="1.0"
install_dir="arch"
buildmodes=('iso')
## Boot modes: BIOS legacy + UEFI (GRUB)
bootmodes=('bios.syslinux' 'uefi.grub')
arch="x86_64"
pacman_conf="pacman.conf"
## Kernel parameters (sustituidos en los .cfg como %KERNEL_PARAMS%)
kernel_params_x86_64="cow_spacesize=10G copytoram=n"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-b' '1M')
# bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/etc/polkit-1/rules.d"]="0:0:750"
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/sudoers.d/10-helix-live"]="0:0:440"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/archlatam-installer"]="0:0:755"
  ["/usr/local/bin/pkexec-wrapper"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/customize-profile.sh"]="0:0:755"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/etc/mkinitcpio.d/linux.preset"]="0:0:644"
)
