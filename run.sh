#!/bin/bash

git clone https://android.googlesource.com/platform/system/tools/mkbootimg

# unpack images from oneplus 13 rom
mkdir op13
payload_dumper --partitions pvmfw,vbmeta,vbmeta_system,vbmeta_vendor --out op13 $OP13_ROM_URL

# unpack images from oneplus 12 rom
mkdir op12
payload_dumper --partitions system,system_ext,product,vbmeta,vbmeta_system,vbmeta_vendor,vendor_boot --out op12 $OP12_ROM_URL

# resign vbmeta_system of oneplus 12 with pvmfw
bash remake.sh vbmeta_system_mod.img op12/vbmeta_system.img

# mod vendor_boot image oneplus 12
mkbootimg_args=`python3 mkbootimg/unpack_bootimg.py --boot_img op12/vendor_boot.img --out unpack --format mkbootimg`
sed -i 's/androidboot.hypervisor.protected_vm.supported=0/androidboot.hypervisor.protected_vm.supported=true/g' unpack/bootconfig
python3 mkbootimg/mkbootimg.py --vendor_boot vendor_boot_mod.img $mkbootimg_args

# resign modified vendor_boot
bash resign.sh vendor_boot_mod.img op12/vendor_boot.img

# prepare output
mkdir out
mv op13/pvmfw.img out/
mv vbmeta_system_mod.img out/
mv vendor_boot_mod.img out/
mv op12/vbmeta_system.img out/
mv op12/vendor_boot.img out/

