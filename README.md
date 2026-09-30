# fog-kernel — Redmi 10C (fog) custom kernel builds

Automated kernel builds for the **Xiaomi Redmi 10C** (codename `fog`,
Snapdragon 680 / SM6225) via GitHub Actions.

## What it builds

- **Base:** [`alternoegraha/kernel_xiaomi_sm6225`](https://github.com/alternoegraha/kernel_xiaomi_sm6225),
  branch `fog-ksu` (Linux 4.19 CAF)
- **Root:** [RKSU](https://github.com/rsuntk/KernelSU) (Rissu's KernelSU fork),
  branch `susfs-rksu-master` — manual hooks (default on non-GKI)
- **Root hiding:** SuSFS kernel-side patch (from a proven fog tree),
  `CONFIG_KSU_SUSFS` + SUS_PATH, SUS_MOUNT, SUS_KSTAT, SUS_MAP,
  OPEN_REDIRECT, SPOOF_UNAME, SPOOF_CMDLINE_OR_BOOTCONFIG,
  HIDE_KSU_SUSFS_SYMBOLS, TRY_UMOUNT
- **Memory:** UKSM (Ultra Kernel Samepage Merging)
- **Network:** BBRv3 TCP congestion control (default)
- **Tweaks:** zram with zstd, PSI, FQ scheduler, DT2W (FocalTech)

> **Manager app:** use the **RKSU Manager** (not ReSukiSU Manager) with this build.

## How to trigger a build

1. Go to the **Actions** tab → **Build fog kernel** workflow.
2. Click **Run workflow** → **Run workflow**.
3. When finished, download the flashable zip from the run's **Artifacts**.

## Layout

| Path | Purpose |
|---|---|
| `patches/01-makefile-includes.patch` | Build-system include-path fixes (base tree needs these to compile with clang) |
| `patches/02-rksu-manual-hooks.patch` | RKSU manual-hook call sites (`fs/stat.c`, `fs/exec.c`, `kernel/reboot.c`, `fs/read_write.c`, `drivers/input/input.c`) |
| `patches/03-uksm.patch` | UKSM memory deduplication |
| `patches/04-bbrv3.patch` | BBRv3 TCP congestion control backport |
| `patches/05-defconfig.patch` | Defconfig: RKSU + SuSFS, UKSM, zstd, BBR, PSI |
| `patches/06-rksu-susfs.patch` | Kernel-side SuSFS (`fs/susfs.c`, hooks in `fs/`, `kernel/`, `security/`) |
| `scripts/setup-rksu.sh` | Swaps stock KernelSU for RKSU susfs branch (run after patches) |
| `anykernel/` | AnyKernel3 packager (flashable zip template) |

## Reproducing locally

```bash
git clone --depth 1 --branch fog-ksu \
  https://github.com/alternoegraha/kernel_xiaomi_sm6225 kernel
cd kernel
for p in ../patches/*.patch; do git apply "$p"; done
../scripts/setup-rksu.sh
# then build with WeebX-Clang 19.1.5 + LineageOS GCC 4.9, see .github/workflows/build.yml
```
