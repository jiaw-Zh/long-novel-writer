#!/usr/bin/env bash
# lib/snapshot.sh — 记忆层快照

cmd_snapshot() {
  local ch="${1:-}"
  [[ -z "$ch" ]] && { echo "用法：lnw snapshot <chapter_num> [--note '备注']" >&2; exit 1; }

  local note=""
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --note) note="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  local snap="snapshots/ch-$(printf '%04d' "$ch")"
  if [[ -d "$snap" ]]; then
    echo "快照已存在：$snap（跳过）"
    return 0
  fi

  mkdir -p "$snap"

  # 只复制记忆层，不复制正文
  for item in entities canon summaries dialogue-samples; do
    [[ -d "$item" ]] && cp -r "$item" "$snap/"
  done
  for item in foreshadowing-ledger.md subplots.md naming.md; do
    [[ -f "$item" ]] && cp "$item" "$snap/"
  done

  # 找本章故事日
  local story_day=""
  local idx_file
  idx_file=$(find chapters -name "chapter-$(printf '%04d' "$ch").index.md" 2>/dev/null | head -1)
  if [[ -f "$idx_file" ]]; then
    story_day=$(grep -E '^time:' "$idx_file" | head -1 | sed 's/time: *//' | tr -d '"')
  fi

  cat > "$snap/snapshot-meta.md" <<EOF
# 快照元信息
- 触发章节：第 $ch 章
- 快照时间：$(date -I)
- 故事日：${story_day:-未知}
- 备注：${note:-（无）}
EOF

  echo "✓ 快照已创建：$snap"
}
