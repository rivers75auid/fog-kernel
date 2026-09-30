#!/bin/bash
# Set up RKSU (rsuntk/KernelSU fork) with official SuSFS support.
# Run from the kernel source root after patches 01-06 are applied.
# The kernel-side SuSFS patch (fs/susfs.c etc.) comes from patch 06;
# this script only swaps the KernelSU directory for RKSU's susfs branch.
set -e

RKSU_BRANCH="susfs-rksu-master"
RKSU_REPO="https://github.com/rsuntk/KernelSU"

echo "==> Removing stock KernelSU"
rm -rf KernelSU
rm -f drivers/kernelsu

echo "==> Cloning RKSU branch ${RKSU_BRANCH}"
git clone --depth 1 --branch "${RKSU_BRANCH}" "${RKSU_REPO}" KernelSU

echo "==> Recreating drivers/kernelsu symlink"
ln -s ../KernelSU/kernel drivers/kernelsu

echo "==> RKSU setup done"
ls -la drivers/kernelsu
grep -m1 "SUSFS" KernelSU/kernel/Kconfig || echo "(no SUSFS menu found - check branch)"
