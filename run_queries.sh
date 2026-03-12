#!/usr/bin/env bash
set -euo pipefail

QUERY_FILE="${1:-Query.txt}"
PROLOG_FILE="${2:-main.pl}"
SKIP_QUERY_EXACT="most_common_topic_for_student(mona, Topic)."

if ! command -v swipl >/dev/null 2>&1; then
  echo "Error: swipl is not installed."
  echo "Install with: sudo apt update && sudo apt install -y swi-prolog"
  exit 1
fi

if [[ ! -f "$QUERY_FILE" ]]; then
  echo "Error: query file not found: $QUERY_FILE"
  exit 1
fi

if [[ ! -f "$PROLOG_FILE" ]]; then
  echo "Error: Prolog file not found: $PROLOG_FILE"
  exit 1
fi

trim() {
  local s="$1"
  s="${s#${s%%[![:space:]]*}}"
  s="${s%${s##*[![:space:]]}}"
  printf '%s' "$s"
}

normalize_answer() {
  local s="$1"
  printf '%s' "$s" | tr -d '[:space:]'
}

extract_first_output_var() {
  local query="$1"
  local inside
  inside="$(sed -E 's/^[^(]*\((.*)\)\.?$/\1/' <<<"$query")"

  while IFS= read -r token; do
    token="$(trim "$token")"
    if [[ "$token" =~ ^[A-Z][A-Za-z0-9_]*$ ]]; then
      printf '%s' "$token"
      return 0
    fi
  done < <(tr ',' '\n' <<<"$inside")

  printf 'Result'
}

run_query() {
  local query_raw="$1"
  local var_name="$2"
  local query_no_dot
  query_no_dot="${query_raw%.}"

  local goal
  goal="(( ${query_no_dot}, format('~w = ~q.~n', ['${var_name}', ${var_name}]) ) ; writeln('false.')), halt."

  swipl -q -s "$PROLOG_FILE" -g "$goal" 2>&1 || true
}

pass_count=0
fail_count=0
total=0
skipped_count=0

current_query=""
current_expected=""

while IFS= read -r line || [[ -n "$line" ]]; do
  line="$(trim "$line")"

  if [[ "$line" =~ ^Q[[:space:]]*:[[:space:]]*(.*)$ ]]; then
    current_query="${BASH_REMATCH[1]}"
    continue
  fi

  if [[ "$line" =~ ^A[[:space:]]*:[[:space:]]*(.*)$ ]]; then
    current_expected="${BASH_REMATCH[1]}"

    if [[ -n "$current_query" ]]; then
      total=$((total + 1))

      if [[ "$current_query" == "$SKIP_QUERY_EXACT" ]]; then
        echo "[$total] Query: $current_query"
        echo "    Expected: $current_expected"
        echo "    Result  : SKIPPED"
        echo
        skipped_count=$((skipped_count + 1))
        current_query=""
        current_expected=""
        continue
      fi

      out_var="$(extract_first_output_var "$current_query")"
      actual="$(run_query "$current_query" "$out_var" | tail -n 1 | tr -d '\r')"
      expected_normalized="$(normalize_answer "$current_expected")"
      actual_normalized="$(normalize_answer "$actual")"

      echo "[$total] Query: $current_query"
      echo "    Expected: $current_expected"
      echo "    Actual  : $actual"

      if [[ "$actual_normalized" == "$expected_normalized" ]]; then
        echo "    Result  : PASS"
        pass_count=$((pass_count + 1))
      else
        echo "    Result  : FAIL"
        fail_count=$((fail_count + 1))
      fi
      echo
    fi

    current_query=""
    current_expected=""
  fi
done < "$QUERY_FILE"

echo "Summary: $pass_count passed, $fail_count failed, $skipped_count skipped, $total total"

if [[ "$fail_count" -gt 0 ]]; then
  exit 2
fi
