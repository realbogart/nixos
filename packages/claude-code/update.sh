#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
base_url="https://downloads.claude.ai/claude-code-releases"
version="${1:-$(curl -fsSL "$base_url/latest")}"

curl -fsSL "$base_url/$version/manifest.zst.json" \
  --output "$script_dir/manifest.json"

printf 'Updated Claude Code manifest to %s\n' "$version"
