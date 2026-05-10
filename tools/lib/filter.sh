#!/usr/bin/env bash
# lib/filter.sh — 查询过滤

cmd_filter_facts() {
  local entities="${1:-}"
  [[ -z "$entities" ]] && { echo "用法：lnw filter-facts <slug1,slug2,...>" >&2; exit 1; }
  [[ ! -f "canon/facts.jsonl" ]] && { echo "canon/facts.jsonl 不存在" >&2; exit 1; }

  # 构造 jq 过滤：entity 数组包含任意一个 slug，或 known_by 包含
  local jq_conds=""
  IFS=',' read -ra arr <<< "$entities"
  for slug in "${arr[@]}"; do
    slug="${slug// /}"
    [[ -z "$slug" ]] && continue
    [[ -n "$jq_conds" ]] && jq_conds+=" or "
    jq_conds+="(.entity // [] | index(\"$slug\") != null)"
    jq_conds+=" or (.known_by // [] | index(\"$slug\") != null)"
    jq_conds+=" or (.to == \"$slug\")"
  done

  jq -c "select($jq_conds)" canon/facts.jsonl
}

cmd_last_seen() {
  local slug="${1:-}"
  [[ -z "$slug" ]] && { echo "用法：lnw last-seen <slug>" >&2; exit 1; }

  # 从所有 index.md 的 characters 字段中找最大章节号
  local last_ch=0
  while IFS= read -r idx_file; do
    local ch
    ch=$(grep -E '^chapter:' "$idx_file" | grep -oE '[0-9]+' | head -1 || true)
    [[ -z "$ch" ]] && continue
    if grep -qE "\"$slug\"|'$slug'" "$idx_file" 2>/dev/null; then
      [[ $ch -gt $last_ch ]] && last_ch=$ch
    fi
  done < <(find chapters -name "*.index.md" 2>/dev/null)

  if [[ $last_ch -eq 0 ]]; then
    echo "$slug：未找到出场记录"
  else
    echo "$slug：最后出场第 $last_ch 章"
  fi
}

cmd_stale_subplots() {
  local threshold=20
  [[ "${1:-}" == "--threshold" ]] && threshold="${2:-20}"

  [[ ! -f "subplots.md" ]] && { echo "subplots.md 不存在"; return; }

  # 找当前最大章节号
  local max_ch=0
  while IFS= read -r idx_file; do
    local ch
    ch=$(grep -E '^chapter:' "$idx_file" | grep -oE '[0-9]+' | head -1 || true)
    [[ -n "$ch" && $ch -gt $max_ch ]] && max_ch=$ch
  done < <(find chapters -name "*.index.md" 2>/dev/null)

  echo "=== 超过 $threshold 章未推进的活跃副线（当前最新章：$max_ch）==="
  # 解析 subplots.md 表格行：| ID | 副线 | 涉及角色 | 当前状态 | 最后推进章节 | 预计回收 |
  awk -F'|' '
    /^\|/ && NF>=7 && !/^\|[-: ]/ && !/ID/ {
      gsub(/^ +| +$/, "", $2); gsub(/^ +| +$/, "", $3)
      gsub(/^ +| +$/, "", $4); gsub(/^ +| +$/, "", $5)
      gsub(/^ +| +$/, "", $6)
      if ($4 !~ /已完结|closed/) {
        # 提取最后推进章节中的数字
        match($6, /[0-9]+/, m)
        if (m[0] != "") print $2, $3, m[0]
      }
    }
  ' subplots.md | while read -r id name last_ch_sub; do
    local gap=$(( max_ch - last_ch_sub ))
    if [[ $gap -ge $threshold ]]; then
      echo "  ⚠️  $id《$name》：已 $gap 章未推进（最后第 ${last_ch_sub} 章）"
    fi
  done
}
