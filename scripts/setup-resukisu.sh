#!/bin/bash
# Replaces the base tree's stock KernelSU with ReSukiSU v4.2.0-rc3.
# Run from the kernel source root, AFTER patches 01-05 are applied.
# The drivers/Makefile + drivers/Kconfig hook lines already exist in the base
# tree (stock-KSU era), so this script only swaps the source itself.
set -euo pipefail

RESUKISU_TAG="v4.2.0-rc3"

echo "==> Removing stock KernelSU..."
rm -f drivers/kernelsu
rm -rf KernelSU

echo "==> Cloning ReSukiSU ${RESUKISU_TAG}..."
git clone --depth 1 --branch "${RESUKISU_TAG}" \
    https://github.com/ReSukiSU/ReSukiSU KernelSU

echo "==> Recreating drivers/kernelsu symlink..."
ln -s ../KernelSU/kernel drivers/kernelsu

echo "==> Verifying..."
test -L drivers/kernelsu && echo "  symlink OK"
test -f KernelSU/kernel/Kconfig && echo "  ReSukiSU source OK"
grep -q 'obj-$(CONFIG_KSU).*kernelsu/' drivers/Makefile && echo "  drivers/Makefile hook OK"
grep -q 'source "drivers/kernelsu/Kconfig"' drivers/Kconfig && echo "  drivers/Kconfig hook OK"
echo "ReSukiSU setup complete."
