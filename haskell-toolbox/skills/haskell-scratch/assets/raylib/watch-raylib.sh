#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
exec nix develop "$HOME/nixos#haskell-toolbox" --command \
  ghcid --command='ghci -ignore-dot-ghci RaylibWindow.hs' --test=Main.mainDev --warnings
