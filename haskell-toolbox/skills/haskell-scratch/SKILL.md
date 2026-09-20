---
name: haskell-scratch
description: Write and run standalone Haskell scripts using Johan's shared Nix toolbox for quick prototypes, graphical apps with h-raylib and live reload, data transformations, algorithm experiments, and executable checks. Use when Haskell is requested or its types and pure functions materially help a scratch task; preserve existing project workflows for application development.
---

# Haskell scratch

Haskell is available as a scripting tool on this machine. Use ordinary `.hs`
files without creating a Cabal project, installing GHC, or copying a flake.
The shared environment is maintained in `~/nixos/haskell-toolbox`.

## Select the environment

Check the current tools and packages rather than assuming their versions:

```sh
command -v ghc runghc ghci
ghc --numeric-version
ghc-pkg list --simple-output
```

For work inside an existing Haskell project, use its established Cabal/Stack
and direnv environment. For independent scratch work, use the shared toolbox.
If the tools are unavailable, run commands through:

```sh
nix develop ~/nixos#haskell-toolbox --command runghc /absolute/path/Script.hs
```

An agent started in an older development shell can inherit a conflicting PATH
or `NIX_GHC_LIBDIR`. Inspect these if compiler versions or package databases
disagree. Select the intended environment for that subprocess; do not modify
the user's global environment or discard a project's intentional settings.

## Write, check, run

Use a unique temporary directory for disposable experiments. Put a requested
reusable script in the user's chosen location or the repository's established
scripts directory. Keep build artifacts out of tracked source directories.

Use normal Prelude and file-local `LANGUAGE` pragmas. Prefer explicit types
for the central data model and pure transformation functions, with IO at the
boundary. Let complexity follow the task; a small script needs no framework.

From the directory whose relative paths the script should use:

```sh
ghc -fno-code -fforce-recomp /absolute/path/Script.hs
runghc /absolute/path/Script.hs argument
ghci -ignore-dot-ghci /absolute/path/Script.hs -e 'expression'
```

Quote paths and arguments appropriately for the shell. Use stdin or files for
large inputs. If local modules are in a different directory, run from that
directory or supply its `-i` include path. For executable scripts, use
`#!/usr/bin/env runghc` and set the executable bit when requested.

Fix compiler errors, then check intended behavior with representative inputs,
edge cases, or properties appropriate to the task. Typechecking alone does
not establish correctness. For transformations that write user data, develop
against sample inputs and temporary outputs before performing authorized writes.

## Libraries and pins

Prefer libraries already in the active package database when they fit. Read
`~/nixos/haskell-toolbox/README.md` when a dependency change or toolchain issue
actually arises. It contains the maintained build and pinning procedures.

The shared dependency set is manually curated. An ordinary scratch request
does not authorize changing it or switching the system configuration. If a
new dependency is necessary and that change is within scope, maintain:

- `haskell-toolbox.cabal`: requested libraries.
- `cabal.project`: Hackage index date and selected Git sources with full commit
  hashes and content hashes.
- `cabal.project.freeze`: exact resolved versions and flags.

Preserve unrelated pins. Do not use `cabal install --lib` or create global GHC
package environments as a workaround. The Nix definition explicitly loads
the freeze file and uses `shellFor` with `exactDeps = true` to avoid ambiguous
imports from duplicate bundled and Git-pinned libraries; retain that behavior.

## Graphical prototypes

For standalone graphical apps, h-raylib and foreign-store are available in
the shared toolbox. Read [the graphics guide](references/graphics.md) and
adapt the [starter files](assets/raylib/) when a window or live graphical
iteration is wanted. The starter's `mainDev` swaps drawing code without
recreating the window, OpenGL context, or animation clock. Use this entry
point for live graphics rather than repeatedly running `main`.

## Live iteration when useful

Default to finite compiler/run commands for autonomous checks. When the user
wants a watcher, use:

```sh
ghcid --command="ghci -ignore-dot-ghci Script.hs" --test=main --warnings
```

This reruns `main` on saves, including its IO effects. Omit `--test=main
--warnings` for typechecking only. Own and stop agent-created watchers when
finished unless the user requested a persistent session. Open tmux panes when
requested, preserving the working directory and selected toolchain.

For a user working in Neovim, `Space h r` saves/runs the file in a terminal
split; `Space h w` starts ghcid in a right-hand tmux pane. `:HaskellRestart`
refreshes HLS after a toolbox update.

Return the result and, for retained scripts, the file location and exact run
command. State what was executed and what the observed checks establish.
