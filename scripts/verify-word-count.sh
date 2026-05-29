#!/usr/bin/env bash
# verify-word-count.sh — 字数门机械检查
# 用法: verify-word-count.sh <file> <target> [tolerance]
# 退出码: 0 = PASS, 2 = TOO SHORT, 3 = TOO LONG

set -euo pipefail

FILE="${1:?用法: verify-word-count.sh <file> <target> [tolerance]}"
TARGET="${2:?用法: verify-word-count.sh <file> <target> [tolerance]}"
TOL="${3:-0.15}"

if [ ! -f "$FILE" ]; then
  echo "FAIL: 文件不存在: $FILE"
  exit 1
fi

COUNT=$(wc -m < "$FILE" | tr -d ' ')
MIN=$(python3 -c "import math; print(math.floor($TARGET * (1 - $TOL)))" 2>/dev/null || python -c "import math; print(math.floor($TARGET * (1 - $TOL)))")
MAX=$(python3 -c "import math; print(math.ceil($TARGET * (1 + $TOL)))" 2>/dev/null || python -c "import math; print(math.ceil($TARGET * (1 + $TOL)))")

echo "=== 字数门检查 ==="
echo "文件: $FILE"
echo "实际字数: $COUNT"
echo "目标区间: [$MIN, $MAX]（目标: $TARGET, 容差: $TOL）"

if [ "$COUNT" -lt "$MIN" ]; then
  deficit=$((MIN - COUNT))
  echo "FAIL: 偏短（差 $deficit 字）"
  echo "建议: 执行 enrich_prompt_v2"
  exit 2
elif [ "$COUNT" -gt "$MAX" ]; then
  excess=$((COUNT - MAX))
  echo "FAIL: 偏长（多 $excess 字）"
  echo "建议: 执行 condense_prompt_v2"
  exit 3
else
  echo "PASS: 字数在区间内"
  exit 0
fi
