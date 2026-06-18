#!/usr/bin/env bash
# verify-pre-writing.sh — 验证 9 步 pre-writing assembly 是否完成
# 用法: verify-pre-writing.sh <novel_dir> <chapter_num>
# 退出码: 0 = PASS, 1 = BLOCKED

set -euo pipefail

NOVEL_DIR="${1:?用法: verify-pre-writing.sh <novel_dir> <chapter_num>}"
CHAPTER_NUM="${2:?用法: verify-pre-writing.sh <novel_dir> <chapter_num>}"
CHAPTER_PAD=$(printf "%04d" "$CHAPTER_NUM")

errors=0
warnings=0

echo "=== Pre-Writing Assembly Verification ==="
echo "小说目录: $NOVEL_DIR"
echo "章节编号: $CHAPTER_NUM"
echo ""

# Step 1: metadata.md + story-bible.md
echo "[Step 1] metadata.md + story-bible.md"
if [ -f "$NOVEL_DIR/metadata.md" ]; then
  echo "  ✓ metadata.md 存在"
else
  echo "  ✗ metadata.md 缺失" && errors=$((errors + 1))
fi
if [ -f "$NOVEL_DIR/story-bible.md" ]; then
  echo "  ✓ story-bible.md 存在"
else
  echo "  ✗ story-bible.md 缺失" && errors=$((errors + 1))
fi

# Step 2: Current volume (L4) + current arc (L3)
echo "[Step 2] 当前 volume + arc 摘要"
vol_found=0
arc_found=0
for f in "$NOVEL_DIR"/volumes/volume-*.md; do
  [ -f "$f" ] && vol_found=1 && echo "  ✓ $(basename "$f") 存在"
done
[ "$vol_found" -eq 0 ] && echo "  ⚠ 无 volume 摘要（降级到 story-bible）" && warnings=$((warnings + 1))
for f in "$NOVEL_DIR"/arcs/arc-*.md; do
  [ -f "$f" ] && arc_found=1 && echo "  ✓ $(basename "$f") 存在"
done
[ "$arc_found" -eq 0 ] && echo "  ⚠ 无 arc 摘要（降级到 story-bible）" && warnings=$((warnings + 1))

# Step 3: Current + next chapter blueprints
echo "[Step 3] 当前 + 下一章 blueprint"
if [ -f "$NOVEL_DIR/blueprints/chapter-${CHAPTER_PAD}.md" ]; then
  echo "  ✓ chapter-${CHAPTER_PAD} blueprint 存在"
else
  echo "  ✗ chapter-${CHAPTER_PAD} blueprint 缺失" && errors=$((errors + 1))
fi
next_pad=$(printf "%04d" "$((CHAPTER_NUM + 1))")
if [ -f "$NOVEL_DIR/blueprints/chapter-${next_pad}.md" ]; then
  echo "  ✓ chapter-${next_pad} blueprint 存在"
else
  echo "  ⚠ chapter-${next_pad} blueprint 缺失（可选）" && warnings=$((warnings + 1))
fi

# Step 4: Recent 3-5 chapter L1 briefs
echo "[Step 4] 最近 3-5 章 L1 briefs"
l1_count=0
if [ "$CHAPTER_NUM" -gt 1 ]; then
  start_seq=$((CHAPTER_NUM > 5 ? CHAPTER_NUM - 5 : 1))
  end_seq=$((CHAPTER_NUM - 1))
  for i in $(seq "$start_seq" "$end_seq"); do
    pad=$(printf "%04d" "$i")
    brief_found=$(find "$NOVEL_DIR/chapters" -name "chapter-${pad}.brief.md" 2>/dev/null | head -1)
    if [ -n "$brief_found" ] && [ -f "$brief_found" ]; then
      l1_count=$((l1_count + 1))
    fi
  done
fi
if [ "$l1_count" -ge 3 ]; then
  echo "  ✓ 找到 $l1_count 份 L1 briefs"
elif [ "$CHAPTER_NUM" -le 1 ]; then
  echo "  ⚠ 第一章，无需 L1 briefs"
else
  echo "  ✗ L1 briefs 不足（找到 $l1_count，需要至少 3）" && errors=$((errors + 1))
fi

# Step 5: Previous chapter ending paragraph
echo "[Step 5] 上一章结尾段落"
prev_num=$((CHAPTER_NUM - 1))
if [ "$prev_num" -ge 1 ]; then
  prev_pad=$(printf "%04d" "$prev_num")
  prev_file="$NOVEL_DIR/chapters"
  # 搜索可能在 volume 子目录下
  prev_found=$(find "$prev_file" -name "chapter-${prev_pad}.md" 2>/dev/null | head -1)
  if [ -n "$prev_found" ] && [ -f "$prev_found" ]; then
    echo "  ✓ 上一章文件存在: $prev_found"
  else
    echo "  ✗ 上一章文件缺失" && errors=$((errors + 1))
  fi
else
  echo "  ⚠ 第一章，无上一章"
fi

# Step 6: Appearing entity files
echo "[Step 6] 实体档案"
entity_dir="$NOVEL_DIR/entities"
if [ -d "$entity_dir" ]; then
  entity_count=$(find "$entity_dir" -name "*.md" 2>/dev/null | wc -l)
  if [ "$entity_count" -gt 0 ]; then
    echo "  ✓ 找到 $entity_count 个实体档案"
  else
    echo "  ⚠ 实体档案目录为空" && warnings=$((warnings + 1))
  fi
else
  echo "  ⚠ 实体档案目录不存在" && warnings=$((warnings + 1))
fi

# Step 7: Foreshadowing ledger
echo "[Step 7] Foreshadowing ledger"
if [ -f "$NOVEL_DIR/foreshadowing-ledger.md" ]; then
  pending=$(grep -c "pending" "$NOVEL_DIR/foreshadowing-ledger.md" 2>/dev/null || echo "0")
  echo "  ✓ foreshadowing-ledger.md 存在（pending: $pending）"
else
  echo "  ⚠ foreshadowing-ledger.md 不存在" && warnings=$((warnings + 1))
fi

# Step 8: Continuity issues + subplots
echo "[Step 8] continuity-issues.md + subplots.md"
if [ -f "$NOVEL_DIR/continuity-issues.md" ]; then
  echo "  ✓ continuity-issues.md 存在"
else
  echo "  ⚠ continuity-issues.md 不存在（可新建）" && warnings=$((warnings + 1))
fi
if [ -f "$NOVEL_DIR/subplots.md" ]; then
  echo "  ✓ subplots.md 存在"
else
  echo "  ⚠ subplots.md 不存在（可新建）" && warnings=$((warnings + 1))
fi

# Step 9: Keyword reverse lookup
echo "[Step 9] 关键词反查索引"
index_count=$(find "$NOVEL_DIR/chapters" -name "chapter-*.index.md" 2>/dev/null | wc -l)
if [ "$index_count" -gt 0 ]; then
  echo "  ✓ 找到 $index_count 个章节索引"
else
  echo "  ⚠ 无章节索引（首次写入时正常）" && warnings=$((warnings + 1))
fi

# Summary
echo ""
echo "=== 验证结果 ==="
echo "错误: $errors | 警告: $warnings"
if [ "$errors" -gt 0 ]; then
  echo "BLOCKED: $errors 项检查未通过，禁止开始写正文"
  exit 1
fi
echo "PASS: Pre-writing assembly 验证通过"
exit 0
