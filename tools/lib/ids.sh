#!/usr/bin/env bash
# lib/ids.sh — ID 自增分配

cmd_next_id() {
  local type="${1:-}"
  case "$type" in
    fact)
      _next_jsonl_id "canon/facts.jsonl" "FACT"
      ;;
    promise)
      _next_jsonl_id "canon/promises.jsonl" "PROMISE"
      ;;
    prog|progression)
      _next_jsonl_id "canon/progression.jsonl" "PROG"
      ;;
    foreshadowing|f)
      _next_ledger_id "foreshadowing-ledger.md" "F"
      ;;
    *)
      echo "用法：lnw next-id <fact|promise|prog|foreshadowing>" >&2
      exit 1
      ;;
  esac
}

# 从 jsonl 文件中找最大数字 ID 并 +1
_next_jsonl_id() {
  local file="$1" prefix="$2"
  local last=0
  if [[ -f "$file" ]]; then
    last=$(grep -oE "\"${prefix}-[0-9]+" "$file" \
           | grep -oE '[0-9]+$' \
           | sort -n | tail -1 || echo 0)
    last=${last:-0}
  fi
  printf "%s-%04d\n" "$prefix" $((10#$last + 1))
}

# 从 markdown 表格中找最大数字 ID 并 +1
_next_ledger_id() {
  local file="$1" prefix="$2"
  local last=0
  if [[ -f "$file" ]]; then
    last=$(grep -oE "\| ${prefix}[0-9]+" "$file" \
           | grep -oE '[0-9]+$' \
           | sort -n | tail -1 || echo 0)
    last=${last:-0}
  fi
  printf "%s%03d\n" "$prefix" $((10#$last + 1))
}
