#!/usr/bin/env bash
# Regenerates the Formulae and Casks tables in README.md from the files in
# Formula/ and Casks/. Name, description and homepage come from each file;
# icons come from .github/tap-icons.txt ("<name> <emoji>" per line).
set -euo pipefail

cd "$(dirname "$0")/../.."

readonly DEFAULT_ICON="📦"
readonly ICONS_FILE=".github/tap-icons.txt"

icon_for() {
  local icon
  icon=$(awk -v name="$1" '$1 == name { print $2; exit }' "$ICONS_FILE")
  printf '%s' "${icon:-$DEFAULT_ICON}"
}

field_of() {
  local field=$1 file=$2
  sed -n "s/^[[:space:]]*${field} \"\(.*\)\"[[:space:]]*\$/\1/p" "$file" | head -n 1
}

table_for() {
  local dir=$1 label=$2 file name desc homepage
  printf '|    | %s | Description |\n' "$label"
  printf '|:--:|---|---|\n'
  for file in "$dir"/*.rb; do
    [ -e "$file" ] || continue
    name=$(basename "$file" .rb)
    desc=$(field_of desc "$file")
    homepage=$(field_of homepage "$file")
    if [ -z "$desc" ] || [ -z "$homepage" ]; then
      echo "error: $file is missing a desc or homepage line" >&2
      exit 1
    fi
    desc=${desc//|/\\|}
    printf '| %s | [`%s`](%s) | %s ([repo](%s)) |\n' \
      "$(icon_for "$name")" "$name" "$file" "$desc" "$homepage"
  done
}

replace_block() {
  local marker=$1 content_file=$2
  if ! grep -qx "<!-- ${marker}:start -->" README.md || ! grep -qx "<!-- ${marker}:end -->" README.md; then
    echo "error: README.md is missing the ${marker} markers" >&2
    exit 1
  fi
  awk -v start="<!-- ${marker}:start -->" -v end="<!-- ${marker}:end -->" -v file="$content_file" '
    $0 == start { print; print ""; while ((getline line < file) > 0) print line; print ""; skip = 1; next }
    $0 == end   { skip = 0 }
    !skip       { print }
  ' README.md > README.md.tmp
  mv README.md.tmp README.md
}

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

table_for Formula Formula > "$tmp_dir/formulae.md"
table_for Casks Cask > "$tmp_dir/casks.md"
replace_block formulae "$tmp_dir/formulae.md"
replace_block casks "$tmp_dir/casks.md"
