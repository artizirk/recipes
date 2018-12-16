#!/bin/sh -e

# Requirements:
# - arch-install-scripts
# - fakeroot
# - squashfs-tools
# - tree

TARGET=minimalbuild

rm -rf minimalbuild && mkdir -p minimalbuild
rm -rf minimalbuild.squashfs

# ffs pacstrap
sudo pacstrap -C ./minimalbuild_pacman.conf -M -G "${TARGET}" base-minimal
find "${TARGET}" -uid 0 -gid 0 -exec sudo chown $(id -u):$(id -g) {} ';'

for p in cache lib log; do
    rm -rf "${TARGET}/var/${p}"
done

echo ">>> Raw installation size" >> minimalbuild_report.txt
du -sh "${TARGET}"  | tee -a minimalbuild_report.txt
echo >> minimalbuild_report.txt
tree -s "${TARGET}" | tee -a minimalbuild_report.txt

echo >> minimalbuild_report.txt
echo ">>> squashfs-ed size" >> minimalbuild_report.txt
fakeroot mksquashfs "${TARGET}"/. minimalbuild.squashfs | tee -a minimalbuild_report.txt
echo >> minimalbuild_report.txt
du -sh minimalbuild.squashfs | tee -a minimalbuild_report.txt
