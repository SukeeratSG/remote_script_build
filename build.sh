#!/bin/bash

# Export some variables

user=sukeerat
OUT_PATH="out/target/product/""$device_codename"
ROM_ZIP=${rom_name}*"$device_codename"*.zip
START=$(date +%s)

# Move into bash directory 

cd "/home/sukeerat/roms/""$rom_name"

# With Gapps

if [ "$with_gapps" = "yes" ];
then
export "$gapps_command"=true
export TARGET_GAPPS_ARCH=arm64
fi

if [ "$with_gapps" = "no" ];
then
export "$gapps_command"=false
fi

if [ "$sync_source" = "yes" ];
then
rm -rf *
repo sync -c -f --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all) --no-tag
fi

# Clean build

if [ "$make_clean" = "yes" ];
then
make clean && make clobber
rm -rf out/ #make clean doesn't work for A11
wait
echo -e ${cya}"OUT dir from your repo deleted"${txtrst};
fi

if [ "$make_clean" = "installclean" ];
then
make installclean
rm -rf ${OUT_PATH}/${ROM_ZIP}
wait
echo -e ${cya}"Images deleted from OUT dir"${txtrst};
fi

# Clean rom zip in any case

rm -rf ${OUT_PATH}/${ROM_ZIP}  

# Time to build

source build/envsetup.sh
lunch "$rom_name"_"$device_codename"-"$build_type"

# Use brunch

if [ "$use_brunch" = "yes" ];
then
brunch "$device_codename"
fi

if [ "$use_brunch" = "no" ];
then
make  "$rom_name" -j$(nproc --all)
fi

if [ "$use_brunch" = "bacon" ];
then
make  bacon -j$(nproc --all)
fi

END=$(date +%s)
TIME=$(echo $((${END}-${START})) | awk '{print int($1/60)" Minutes and "int($1%60)" Seconds"}')

# Upload on sourceforge 

sshpass="Your password here"
~/sshpass -e sftp -oBatchMode=no -b - IrongFly@frs.sourceforge.net << !
     cd /home/frs/project/project_about_cats
     put ${ROM_ZIP}
     bye
!