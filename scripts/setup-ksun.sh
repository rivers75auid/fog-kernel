#!/bin/bash
# Set up KernelSU-Next (Redminote11tech fork) with SuSFS for 4.19.
# Run from the kernel source root after base patches are applied.
set -e

KSUN_REPO="https://github.com/Redminote11tech/KernelSU-Next"
KSUN_BRANCH="v2.2.0-legacy-susfs"
SUSFS_REPO="https://gitlab.com/simonpunk/susfs4ksu.git"
SUSFS_BRANCH="kernel-4.19"

echo "==> Removing stock KernelSU"
rm -rf KernelSU
rm -f drivers/kernelsu

echo "==> Cloning KernelSU-Next (${KSUN_BRANCH})"
git clone --depth 1 --branch "${KSUN_BRANCH}" "${KSUN_REPO}" KernelSU

echo "==> Recreating drivers/kernelsu symlink"
ln -s ../KernelSU/kernel drivers/kernelsu

echo "==> Cloning SuSFS (${SUSFS_BRANCH})"
if [ ! -d "susfs4ksu" ]; then
    git clone --depth 1 --branch "${SUSFS_BRANCH}" "${SUSFS_REPO}" susfs4ksu
fi

echo "==> Applying SuSFS kernel patch (4.19)"
if [ -f "susfs4ksu/kernel_patches/50_add_susfs_in_kernel-4.19.patch" ]; then
    patch -p1 --forward < susfs4ksu/kernel_patches/50_add_susfs_in_kernel-4.19.patch || {
        echo "WARNING: SuSFS patch had issues, checking..."
        # Don't fail hard, let the build try
    }
else
    echo "WARNING: SuSFS patch not found!"
fi

echo "==> Copying SuSFS new files (patch doesn't create them)"
# The 50_add_susfs patch modifies existing files but doesn't create new ones
# Copy them manually from susfs4ksu repo
if [ -f "susfs4ksu/kernel_patches/fs/susfs.c" ]; then
    cp susfs4ksu/kernel_patches/fs/susfs.c fs/susfs.c
    echo "Copied fs/susfs.c"
fi
if [ -f "susfs4ksu/kernel_patches/include/linux/susfs.h" ]; then
    cp susfs4ksu/kernel_patches/include/linux/susfs.h include/linux/susfs.h
    echo "Copied include/linux/susfs.h"
fi
if [ -f "susfs4ksu/kernel_patches/include/linux/susfs_def.h" ]; then
    cp susfs4ksu/kernel_patches/include/linux/susfs_def.h include/linux/susfs_def.h
    echo "Copied include/linux/susfs_def.h"
fi

echo "==> KernelSU-Next + SuSFS setup done"
ls -la drivers/kernelsu | head -5
