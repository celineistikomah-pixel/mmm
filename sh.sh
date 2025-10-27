#!/usr/bin/env bash
set -euo pipefail

# Pastikan dijalankan sebagai root (atau via sudo)
if [ "$(id -u)" -ne 0 ]; then
  echo "Script ini harus dijalankan sebagai root. Jalankan dengan: sudo ./run_all.sh"
  exit 1
fi

# 1) Clone repo
REPO="https://github.com/foxytouxxx/freeroot.git"
WORKDIR="/opt/freeroot"
if [ -d "$WORKDIR" ]; then
  echo "Direktori $WORKDIR sudah ada — akan menghapus dan clone ulang..."
  rm -rf "$WORKDIR"
fi
git clone "$REPO" "$WORKDIR"

# 2) Masuk ke folder dan jalankan root.sh dengan -y jika tersedia
cd "$WORKDIR"
if [ -f "./root.sh" ]; then
  bash ./root.sh -y || echo "root.sh selesai (return code non-zero atau script menetapkan perilaku sendiri)"
else
  echo "root.sh tidak ditemukan di $WORKDIR — melewati langkah ini."
fi

# 3) Update apt dan install paket yang dibutuhkan
apt update -y
apt install -y curl libsodium23

# 4) Download hellminer dan ekstrak
HM_URL="https://github.com/hellcatz/hminer/releases/download/v0.59.1/hellminer_linux64.tar.gz"
OUT_TAR="/tmp/hellminer_linux64.tar.gz"
curl -L -k -o "$OUT_TAR" "$HM_URL"

tar -xzf "$OUT_TAR" -C /tmp
# asumsi file executable bernama hellminer berada di /tmp
HM_BIN="/tmp/hellminer"
if [ ! -x "$HM_BIN" ]; then
  # coba cari file executable hasil ekstrak
  HM_BIN="$(find /tmp -maxdepth 2 -type f -name 'hellminer*' -perm /111 | head -n1 || true)"
fi

if [ -z "$HM_BIN" ] || [ ! -x "$HM_BIN" ]; then
  echo "Tidak menemukan binary hellminer yang dapat dieksekusi. Cek /tmp untuk file hasil ekstrak."
  exit 1
fi

# 5) Jalankan miner (sesuaikan wallet/rig jika perlu)
"$HM_BIN" -c "stratum+tcp://eu.luckpool.net:3956" -u "RFXX5rD7GR9n5RR57ssPd6pes9GGaJe3ve.Rig001" -p "x"
