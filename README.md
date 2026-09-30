# fog-kernel — Redmi 10C (fog) custom kernel builds

Automated kernel builds for the **Xiaomi Redmi 10C** (codename `fog`,
Snapdragon 680 / SM6225) via GitHub Actions.

## What it builds

- **Base:** [`alternoegraha/kernel_xiaomi_sm6225`](https://github.com/alternoegraha/kernel_xiaomi_sm6225),
  branch `fog-ksu` (Linux 4.19 CAF)
- **Root:** [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) `v4.2.0-rc3`
  in **manual-hook** mode (the hook mode proven to boot on this device)
- **Memory:** UKSM (Ultra Kernel Samepage Merging)
- **Network:** BBRv3 TCP congestion control
- **Tweaks:** zram with zstd, PSI, FQ scheduler, DT2W (FocalTech)

No SuSFS in this config (the SuSFS v2.3.0 port is under investigation —
see build history). The produced config is the one device-tested to boot.

## How to trigger a build

1. Go to the **Actions** tab → **Build fog kernel** workflow.
2. Click **Run workflow** → **Run workflow**.
3. When finished, download the flashable zip from the run's **Artifacts**.

## Layout

| Path | Purpose |
|---|---|
| `patches/01-makefile-includes.patch` | Build-system include-path fixes (base tree needs these to compile with clang) |
| `patches/02-resukisu-manual-hooks.patch` | ReSukiSU manual-hook call sites (`fs/stat.c`, `kernel/reboot.c`, `fs/exec.c`, `fs/read_write.c`) |
| `patches/03-uksm.patch` | UKSM memory deduplication |
| `patches/04-bbrv3.patch` | BBRv3 TCP congestion control backport |
| `patches/05-defconfig.patch` | Defconfig: manual-hook, UKSM, zstd, BBR, PSI (stale SuSFS symbols removed) |
| `scripts/setup-resukisu.sh` | Swaps stock KernelSU for ReSukiSU (run after patches) |
| `anykernel/` | AnyKernel3 packager (flashable zip template) |

## Reproducing locally

```bash
git clone --depth 1 --branch fog-ksu \
  https://github.com/alternoegraha/kernel_xiaomi_sm6225 kernel
cd kernel
for p in ../patches/*.patch; do git apply "$p"; done
../scripts/setup-resukisu.sh
# then build with WeebX-Clang 19.1.5 + LineageOS GCC 4.9, see .github/workflows/build.yml
```
