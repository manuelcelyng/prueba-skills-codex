#!/usr/bin/env bash
compute_relpath() {
  local micro_rel="$1"
  local target="$2"
  local depth=0
  local tmp="$micro_rel"
  while [ -n "$tmp" ]; do
    case "$tmp" in
      */*)
        depth=$((depth + 1))
        tmp="${tmp#*/}"
        ;;
      *)
        depth=$((depth + 1))
        tmp=""
        ;;
    esac
  done
  local ups=""
  local i=0
  local total=$((depth + 1))
  while [ "$i" -lt "$total" ]; do
    if [ -n "$ups" ]; then
      ups="$ups/.."
    else
      ups=".."
    fi
    i=$((i + 1))
  done
  echo "${ups}/${target}"
}

pass=0
fail=0

test_relpath() {
  local micro="$1" target="$2" expected="$3"
  local result
  result="$(compute_relpath "$micro" "$target")"
  if [ "$result" = "$expected" ]; then
    echo "PASS: compute_relpath '$micro' '$target' = '$result'"
    pass=$((pass + 1))
  else
    echo "FAIL: compute_relpath '$micro' '$target' = '$result' (expected '$expected')"
    fail=$((fail + 1))
  fi
}

test_relpath "micro-a" ".kiro/skills" "../../.kiro/skills"
test_relpath "micro-a" ".kiro/steering" "../../.kiro/steering"
test_relpath "micro-a" ".codex/references" "../../.codex/references"
test_relpath "group/micro-b" ".kiro/skills" "../../../.kiro/skills"
test_relpath "a/b/c" ".kiro/skills" "../../../../.kiro/skills"

echo ""
echo "Results: $pass passed, $fail failed"
exit $fail
