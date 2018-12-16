#!/bin/sh -e

# Requirements:
# - arch-install-scripts
# - diffutils
# - fakeroot
# - squashfs-tools
# - tree

TARGET=minimalbuild

rm -rf minimalbuild && mkdir -p minimalbuild
rm -rf minimalbuild.squashfs

if [ -f ./minimalbuild_report.txt ]; then
    if [ -f ./minimalbuild_report.txt.old ]; then
        rm minimalbuild_report.txt.old
    fi
    mv minimalbuild_report.txt minimalbuild_report.txt.old
fi

# ffs pacstrap
sudo pacstrap -C ./minimalbuild_pacman.conf -M -G "${TARGET}" base-minimal
find "${TARGET}" -uid 0 -gid 0 -exec sudo chown $(id -u):$(id -g) {} ';'

for p in cache lib log; do
    rm -rf "${TARGET}/var/${p}"
done
rm -rf "${TARGET}/usr/share/licenses"

echo ">>> Raw installation size" >> minimalbuild_report.txt
du -sh "${TARGET}"  | tee -a minimalbuild_report.txt
echo >> minimalbuild_report.txt
tree -s "${TARGET}" | tee -a minimalbuild_report.txt

echo >> minimalbuild_report.txt
echo ">>> squashfs-ed size" >> minimalbuild_report.txt
fakeroot mksquashfs "${TARGET}"/. minimalbuild.squashfs -comp zstd | tee -a minimalbuild_report.txt
echo >> minimalbuild_report.txt
du -sh minimalbuild.squashfs | tee -a minimalbuild_report.txt

if [ -f minimalbuild_report.txt.old ]; then
    echo ""
    echo ">>> Comparision with previous build"
    diff --color --unified minimalbuild_report.txt.old minimalbuild_report.txt || true
fi
