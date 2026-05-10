#!/usr/bin/env bash
# lib/assemble.sh — 写前上下文组装（9段）

cmd_assemble_context() {
  local ch="${1:-}"
  [[ -z "$ch" ]] && { echo "用法：lnw assemble-context <chapter_num>" >&2; exit 1; }

  local padded
  padded=$(printf "%04d" "$ch")
  local idx_file
  idx_file=$(find chapters -name "chapter-${padded}.index.md" 2>/dev/null | head -1)

  # 从 index.md 提取字段（兼容 yq 不可用的情况）
  _get_index_field() {
    local field="$1"
    if command -v yq &>/dev/null && [[ -f "$idx_file" ]]; then
      yq ".$field" "$idx_file" 2>/dev/null || true
    elif [[ -f "$idx_file" ]]; then
      grep -E "^${field}:" "$idx_file" | head -1 | sed "s/${field}: *//" | tr -d '"'
    fi
  }

  local volume arc
  volume=$(_get_index_field volume)
  arc=$(_get_index_field arc)

  # 出场角色列表（从 index.md 的 characters 字段）
  local chars=()
  if [[ -f "$idx_file" ]]; then
    while IFS= read -r c; do
      c="${c//[\[\]\"' ]/}"
      [[ -n "$c" ]] && chars+=("$c")
    done < <(grep -E '^characters:' "$idx_file" | sed 's/characters: *//' | tr ',' '\n' | tr -d '[]')
  fi

  # 关键词列表
  local keywords=()
  if [[ -f "$idx_file" ]]; then
    while IFS= read -r k; do
      k="${k//[\[\]\"' ]/}"
      [[ -n "$k" ]] && keywords+=("$k")
    done < <(grep -E '^keywords:' "$idx_file" | sed 's/keywords: *//' | tr ',' '\n' | tr -d '[]')
  fi

  _section() { echo; echo "===== $1 ====="; echo; }

  # 1. metadata + story-bible
  _section "1. 元信息 + 设定正典"
  [[ -f "metadata.md" ]] && cat metadata.md
  [[ -f "story-bible.md" ]] && cat story-bible.md

  # 2. 当前卷 + 篇章摘要
  _section "2. 当前卷摘要 + 篇章摘要"
  if [[ -n "$volume" && "$volume" != "null" ]]; then
    local vol_file="volumes/volume-$(printf '%03d' "$volume").md"
    [[ -f "$vol_file" ]] && cat "$vol_file"
  fi
  if [[ -n "$arc" && "$arc" != "null" ]]; then
    local arc_file="arcs/arc-$(printf '%03d' "$arc").md"
    [[ -f "$arc_file" ]] && cat "$arc_file"
  fi

  # 3. 当前章 + 下一章 blueprint（从 volumes.md 或 blueprint 文件）
  _section "3. 章节 Blueprint"
  echo "（请从章节目录文件中提取第 $ch 章和第 $((ch+1)) 章的 blueprint）"

  # 4. 最近 5 章 L1 brief
  _section "4. 最近 5 章摘要（L1）"
  for i in $(seq $((ch-5)) $((ch-1))); do
    [[ $i -le 0 ]] && continue
    local brief
    brief=$(find chapters -name "chapter-$(printf '%04d' "$i").brief.md" 2>/dev/null | head -1)
    if [[ -f "$brief" ]]; then
      echo "--- 第 $i 章 ---"
      cat "$brief"
    fi
  done

  # 5. 上一章结尾段原文（约 800 字 ≈ 2400 bytes）
  _section "5. 上一章结尾段"
  local prev_ch_file
  prev_ch_file=$(find chapters -name "chapter-$(printf '%04d' $((ch-1))).md" \
                 ! -name "*.brief.md" ! -name "*.index.md" 2>/dev/null | head -1)
  if [[ -f "$prev_ch_file" ]]; then
    tail -c 2400 "$prev_ch_file"
  else
    echo "（第一章，无前章）"
  fi

  # 6. 出场角色档案 + 已知秘密 + 台词样本
  _section "6. 出场角色档案 + 已知秘密 + 台词样本"
  for slug in "${chars[@]}"; do
    echo "--- $slug ---"
    local entity_file="entities/characters/${slug}.md"
    [[ -f "$entity_file" ]] && cat "$entity_file"
    echo "【已知秘密】"
    if [[ -f "canon/facts.jsonl" ]]; then
      jq -c "select((.known_by // [] | index(\"$slug\") != null) or (.to == \"$slug\"))" \
         canon/facts.jsonl 2>/dev/null || true
    fi
    local sample_file="dialogue-samples/${slug}.md"
    if [[ -f "$sample_file" ]]; then
      echo "【台词样本】"
      cat "$sample_file"
    fi
    echo
  done

  # 7. 活跃伏笔
  _section "7. 活跃伏笔"
  if [[ -f "foreshadowing-ledger.md" ]]; then
    awk '/待回收|强化中/' foreshadowing-ledger.md || echo "（无活跃伏笔）"
  fi

  # 8. 禁用桥段 + 失踪副线 + 到期承诺
  _section "8. 禁用桥段 / 失踪副线 / 到期承诺"
  if [[ -f "continuity-issues.md" ]]; then
    awk '/## 禁用桥段/{found=1} found{print} /## 已修复/{found=0}' continuity-issues.md
  fi
  cmd_stale_subplots 2>/dev/null || true
  if [[ -f "canon/promises.jsonl" ]]; then
    local story_day
    story_day=$(_get_index_field time | grep -oE '[0-9]+' | head -1)
    if [[ -n "$story_day" ]]; then
      echo "【即将到期承诺（±200天）】"
      jq -c "select(.status == \"pending\" and .deadline_day != null and
             (.deadline_day >= ($story_day - 200)) and
             (.deadline_day <= ($story_day + 200)))" \
         canon/promises.jsonl 2>/dev/null || true
    fi
  fi

  # 9. 关键词检索命中的相关章节 L1
  _section "9. 关键词检索（相关章节 L1）"
  local seen=()
  for kw in "${keywords[@]}"; do
    while IFS= read -r hit_idx; do
      local hit_brief="${hit_idx/.index.md/.brief.md}"
      # 去重，排除本章
      local hit_ch
      hit_ch=$(grep -E '^chapter:' "$hit_idx" | grep -oE '[0-9]+' | head -1 || true)
      [[ "$hit_ch" == "$ch" ]] && continue
      [[ " ${seen[*]} " == *" $hit_ch "* ]] && continue
      seen+=("$hit_ch")
      if [[ -f "$hit_brief" ]]; then
        echo "--- 第 $hit_ch 章（关键词：$kw）---"
        cat "$hit_brief"
      fi
    done < <(grep -rl "$kw" chapters/*/chapter-*.index.md 2>/dev/null | head -3)
    [[ ${#seen[@]} -ge 5 ]] && break
  done
}
