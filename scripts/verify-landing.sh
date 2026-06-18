#!/usr/bin/env bash
# verify-landing.sh — 验证 chapter landing 后文件完整性
# 用法: verify-landing.sh <novel_dir> <chapter_num>
# 退出码: 0 = PASS, 1 = FAIL

set -euo pipefail

NOVEL_DIR="${1:?用法: verify-landing.sh <novel_dir> <chapter_num>}"
CHAPTER_NUM="${2:?用法: verify-landing.sh <novel_dir> <chapter_num>}"
CHAPTER_PAD=$(printf "%04d" "$CHAPTER_NUM")

errors=0

echo "=== Landing Verification ==="
echo "小说目录: $NOVEL_DIR"
echo "章节编号: $CHAPTER_NUM"
echo ""

# 1. L0 正文
echo "[1] L0 正文"
l0_found=$(find "$NOVEL_DIR/chapters" -name "chapter-${CHAPTER_PAD}.md" 2>/dev/null | head -1)
if [ -n "$l0_found" ] && [ -f "$l0_found" ]; then
  chars=$(tr -d '[:space:]' < "$l0_found" | wc -m | tr -d ' ')
  echo "  ✓ chapter-${CHAPTER_PAD}.md 存在（$chars 字符）"
else
  echo "  ✗ chapter-${CHAPTER_PAD}.md 缺失" && errors=$((errors + 1))
fi

# 2. L1 brief (frozen)
echo "[2] L1 brief"
brief_found=$(find "$NOVEL_DIR/chapters" -name "chapter-${CHAPTER_PAD}.brief.md" 2>/dev/null | head -1)
if [ -n "$brief_found" ] && [ -f "$brief_found" ]; then
  echo "  ✓ chapter-${CHAPTER_PAD}.brief.md 存在 ($brief_found)"
else
  echo "  ✗ chapter-${CHAPTER_PAD}.brief.md 缺失" && errors=$((errors + 1))
fi

# 3. YAML index
echo "[3] YAML 章节索引"
index_found=$(find "$NOVEL_DIR/chapters" -name "chapter-${CHAPTER_PAD}.index.md" 2>/dev/null | head -1)
if [ -n "$index_found" ] && [ -f "$index_found" ]; then
  echo "  ✓ chapter-${CHAPTER_PAD}.index.md 存在 ($index_found)"
else
  echo "  ✗ chapter-${CHAPTER_PAD}.index.md 缺失" && errors=$((errors + 1))
fi

# 4. Canon facts.jsonl
echo "[4] Canon facts.jsonl"
if [ -f "$NOVEL_DIR/canon/facts.jsonl" ]; then
  echo "  ✓ canon/facts.jsonl 存在"
else
  echo "  ✗ canon/facts.jsonl 缺失" && errors=$((errors + 1))
fi

# 5. Canon promises.jsonl
echo "[5] Canon promises.jsonl"
if [ -f "$NOVEL_DIR/canon/promises.jsonl" ]; then
  echo "  ✓ canon/promises.jsonl 存在"
else
  echo "  ✗ canon/promises.jsonl 缺失" && errors=$((errors + 1))
fi

# 6. Canon progression.jsonl
echo "[6] Canon progression.jsonl"
if [ -f "$NOVEL_DIR/canon/progression.jsonl" ]; then
  echo "  ✓ canon/progression.jsonl 存在"
else
  echo "  ✗ canon/progression.jsonl 缺失" && errors=$((errors + 1))
fi

# 7. Canon timeline.md + rules.md
echo "[7] Canon timeline.md + rules.md"
if [ -f "$NOVEL_DIR/canon/timeline.md" ]; then
  echo "  ✓ canon/timeline.md 存在"
else
  echo "  ✗ canon/timeline.md 缺失" && errors=$((errors + 1))
fi
if [ -f "$NOVEL_DIR/canon/rules.md" ]; then
  echo "  ✓ canon/rules.md 存在"
else
  echo "  ✗ canon/rules.md 缺失" && errors=$((errors + 1))
fi

# 8. Entity files updated (check existence)
echo "[8] 实体档案"
entity_dir="$NOVEL_DIR/entities"
if [ -d "$entity_dir" ]; then
  entity_count=$(find "$entity_dir" -name "*.md" 2>/dev/null | wc -l)
  echo "  ✓ 实体档案目录存在（$entity_count 个文件）"
else
  echo "  ⚠ 实体档案目录不存在"
fi

# 9. Foreshadowing ledger + subplots
echo "[9] Foreshadowing + subplots"
if [ -f "$NOVEL_DIR/foreshadowing-ledger.md" ]; then
  echo "  ✓ foreshadowing-ledger.md 存在"
else
  echo "  ✗ foreshadowing-ledger.md 缺失" && errors=$((errors + 1))
fi
if [ -f "$NOVEL_DIR/subplots.md" ]; then
  echo "  ✓ subplots.md 存在"
else
  echo "  ⚠ subplots.md 不存在"
fi

# 10. Dialogue samples
echo "[10] 对话样本"
if [ -d "$NOVEL_DIR/dialogue-samples" ]; then
  sample_count=$(find "$NOVEL_DIR/dialogue-samples" -name "*.md" 2>/dev/null | wc -l)
  echo "  ✓ dialogue-samples 目录存在（$sample_count 个文件）"
else
  echo "  ⚠ dialogue-samples 目录不存在"
fi

# Summary
echo ""
echo "=== 验证结果 ==="
echo "错误: $errors"
if [ "$errors" -gt 0 ]; then
  echo "FAIL: $errors 项核心文件缺失，landing 不完整"
  exit 1
fi
echo "PASS: Landing 验证通过"
exit 0
