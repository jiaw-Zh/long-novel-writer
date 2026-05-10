#!/usr/bin/env bash
# lib/check.sh — 机械校验（零 LLM）

cmd_check_naming() {
  local ch="${1:-}"
  [[ -z "$ch" ]] && { echo "用法：lnw check-naming <chapter_num>" >&2; exit 1; }

  local chapter_file
  chapter_file=$(_find_chapter_file "$ch")
  [[ ! -f "$chapter_file" ]] && { echo "找不到正文文件（第 $ch 章）" >&2; exit 1; }
  [[ ! -f "naming.md" ]] && { echo "naming.md 不存在，跳过命名检查"; return 0; }

  local hit=0
  # awk 解析表格，跳过表头和分隔行，输出禁用变体列（第4列）
  while IFS=$'\t' read -r variants; do
    [[ -z "$variants" ]] && continue
    IFS='、,' read -ra vlist <<< "$variants"
    for bad in "${vlist[@]}"; do
      bad="$(echo "$bad" | sed 's/^ *//;s/ *$//')"
      [[ -z "$bad" ]] && continue
      if grep -qn "$bad" "$chapter_file" 2>/dev/null; then
        echo "✗ 发现禁用变体「$bad」："
        grep -n "$bad" "$chapter_file" | head -3 | sed 's/^/    /'
        hit=1
      fi
    done
  done < <(awk -F'|' 'NF>=4 && $2 !~ /---/ && $2 !~ /实体/ {
    gsub(/^ +| +$/, "", $4); if ($4) print $4
  }' naming.md)

  [[ $hit -eq 0 ]] && echo "✓ 命名一致性通过（第 $ch 章）"
  return $hit
}

cmd_check_progression() {
  local ch="${1:-}"
  [[ -z "$ch" ]] && { echo "用法：lnw check-progression <chapter_num>" >&2; exit 1; }
  [[ ! -f "canon/progression.jsonl" ]] && { echo "canon/progression.jsonl 不存在，跳过"; return 0; }

  local hit=0
  while IFS= read -r entry; do
    local entity system value
    entity=$(echo "$entry" | jq -r '.entity')
    system=$(echo "$entry" | jq -r '.system')
    value=$(echo "$entry" | jq -r '.value | tonumber')

    local max_before
    max_before=$(jq -r "select(.entity == \"$entity\" and .system == \"$system\" and .chapter < $ch) | .value" \
                 canon/progression.jsonl 2>/dev/null \
                 | grep -E '^[0-9]+(\.[0-9]+)?$' | sort -n | tail -1)

    if [[ -n "$max_before" ]] && awk "BEGIN{exit !($value < $max_before)}"; then
      echo "✗ $entity [$system] 第 $ch 章值 $value 低于历史最高 $max_before（境界倒退）"
      hit=1
    fi
  done < <(jq -c "select(.chapter == $ch and (.type == null or .type == \"\"))" \
           canon/progression.jsonl 2>/dev/null || true)

  [[ $hit -eq 0 ]] && echo "✓ 进阶合法性通过（第 $ch 章）"
  return $hit
}

# 根据章节号定位正文文件
_find_chapter_file() {
  local ch=$1
  local padded
  padded=$(printf "%04d" "$ch")
  find chapters -name "chapter-${padded}.md" \
    ! -name "*.brief.md" ! -name "*.index.md" 2>/dev/null | head -1
}
