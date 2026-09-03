#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
requested_version="${1:-}"

if [[ -n "$requested_version" ]]; then
  release_url="https://api.github.com/repos/openai/codex/releases/tags/rust-v$requested_version"
else
  release_url="https://api.github.com/repos/openai/codex/releases/latest"
fi

release_json="$(mktemp)"
manifest_tmp="$script_dir/manifest.json.tmp"
trap 'rm -f "$release_json" "$manifest_tmp"' EXIT

curl -fsSL "$release_url" --output "$release_json"

version="$(sed -n 's/^[[:space:]]*"tag_name": "rust-v\([^"]*\)",/\1/p' "$release_json" | head -n 1)"

asset_checksum() {
  local asset="$1"
  sed -n \
    "/\"name\": \"$asset\"/,/\"browser_download_url\"/s/.*\"digest\": \"sha256:\([0-9a-f]*\)\".*/\1/p" \
    "$release_json"
}

aarch64_codex="$(asset_checksum 'codex-aarch64-unknown-linux-musl.zst')"
aarch64_host="$(asset_checksum 'codex-code-mode-host-aarch64-unknown-linux-musl.zst')"
x86_64_codex="$(asset_checksum 'codex-x86_64-unknown-linux-musl.zst')"
x86_64_host="$(asset_checksum 'codex-code-mode-host-x86_64-unknown-linux-musl.zst')"

for value in "$version" "$aarch64_codex" "$aarch64_host" "$x86_64_codex" "$x86_64_host"; do
  if [[ -z "$value" ]]; then
    printf 'Could not extract complete release metadata from %s\n' "$release_url" >&2
    exit 1
  fi
done

{
  printf '{\n'
  printf '  "version": "%s",\n' "$version"
  printf '  "platforms": {\n'
  printf '    "aarch64-linux": {\n'
  printf '      "target": "aarch64-unknown-linux-musl",\n'
  printf '      "codexChecksum": "%s",\n' "$aarch64_codex"
  printf '      "codeModeHostChecksum": "%s"\n' "$aarch64_host"
  printf '    },\n'
  printf '    "x86_64-linux": {\n'
  printf '      "target": "x86_64-unknown-linux-musl",\n'
  printf '      "codexChecksum": "%s",\n' "$x86_64_codex"
  printf '      "codeModeHostChecksum": "%s"\n' "$x86_64_host"
  printf '    }\n'
  printf '  }\n'
  printf '}\n'
} > "$manifest_tmp"

mv "$manifest_tmp" "$script_dir/manifest.json"
printf 'Updated Codex manifest to %s\n' "$version"
