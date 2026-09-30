#!/bin/bash
# Set up ReSukiSU (manual hooks, no SuSFS).
# Run from the kernel source root after patches 00-05 are applied.
# The manual hook call-sites come from patch 02;
# this script only provides the ReSukiSU KernelSU directory.
set -e

RESUKISU_REPO="https://github.com/ReSukiSU/ReSukiSU"
RESUKISU_BRANCH="main"

echo "==> Removing stock KernelSU"
rm -rf KernelSU
rm -f drivers/kernelsu

echo "==> Cloning ReSukiSU branch ${RESUKISU_BRANCH}"
git clone --depth 1 --branch "${RESUKISU_BRANCH}" "${RESUKISU_REPO}" KernelSU

echo "==> Recreating drivers/kernelsu symlink"
ln -s ../KernelSU/kernel drivers/kernelsu

echo "==> Forcing KSU_MANUAL_HOOK as default (not tracepoint)"
sed -i 's/default KSU_TRACEPOINT_HOOK/default KSU_MANUAL_HOOK/' KernelSU/kernel/Kconfig
grep -m1 "default KSU_MANUAL_HOOK" KernelSU/kernel/Kconfig || echo "(WARNING: Kconfig default not patched)"

echo "==> ReSukiSU setup done"
ls -la drivers/kernelsu
grep -m1 "KSU_MANUAL_HOOK" KernelSU/kernel/Kconfig || echo "(no MANUAL_HOOK found - check branch)"
