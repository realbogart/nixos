# Haskell anywhere

This is one shared dependency project for standalone scripts. It supplies GHC
9.14.1, HLS 2.15.0.0, Cabal 3.16.1.0, Ormolu, and the libraries listed in
`haskell-toolbox.cabal`. Your scripts do not need Cabal files or direnv.

## Install and use

Build independently, then install through the usual NixOS configuration:

```sh
nix build ~/nixos#haskell-toolbox
sudo nixos-rebuild switch --flake ~/nixos#monstret
```

Use `#desktop` or `#default` on those machines. Open a fresh terminal outside
an existing direnv environment after activation. If this terminal was started
inside an older Haskell shell, exit that shell first: its PATH and
`NIX_GHC_LIBDIR` can still select the old compiler.

```sh
cd /tmp
nvim experiment.hs
runghc experiment.hs argument
ghci experiment.hs
```

For an executable script, start it with `#!/usr/bin/env runghc`, then use
`chmod +x experiment.hs`. Relative file operations use the caller's working
directory. Language extensions belong in each script's `LANGUAGE` pragmas;
normal Prelude is available by default.

Neovim starts HLS through your existing haskell-tools plugin. Completion,
hover, diagnostics, and Ormolu formatting work on loose files. After replacing
the installed toolbox, run `:HaskellRestart` or reopen Neovim. Fresh sessions
are necessary if the editor inherited an old project environment.

Files under an existing Cabal/Stack project use that project's dependencies.
Start Neovim from the project's direnv-enabled shell to use its compiler and
HLS. The shared toolbox does not export global GHC package-path variables.

For a temporary shell before system activation:

```sh
nix develop ~/nixos#haskell-toolbox
```

## Run automatically on save

In a second terminal (or tmux pane), start:

```sh
ghcid --command="ghci -ignore-dot-ghci script.hs" --test=main --warnings
```

This keeps GHCi running, watches the script and loaded local modules, reloads
on save, and runs `main` after each successful reload. Type errors are shown
instead of running; `--warnings` allows execution when there are only warnings.
Changes must be saved to disk. Stop the watcher with Ctrl-C.

For typechecking only, omit `--test=main --warnings`. To pass script arguments,
use `--test=':main argument1 argument2'`. Relative file operations use the
terminal's working directory. Add `--reload=input.json` to also watch a data
file. Restart ghcid after installing a changed toolbox dependency set.

## Add or change libraries


1. Edit `build-depends` in `haskell-toolbox.cabal` (for example, add `aeson`).
2. Add any Git source overrides to `cabal.project`.
3. Regenerate and review the freeze file using the installed toolbox:

   ```sh
   cd ~/nixos/haskell-toolbox
   cabal update
   cabal freeze
   git diff -- cabal.project cabal.project.freeze haskell-toolbox.cabal
   nix build ~/nixos#haskell-toolbox
   sudo nixos-rebuild switch --flake ~/nixos#monstret
   ```

`cabal freeze` respects existing constraints. To change a frozen version, edit
or remove that package's constraint first, and regenerate. For an intentional
full dependency refresh, move the old freeze file aside, regenerate, and review
the complete diff. If using a temporary development shell, enter it **before**
making dependency changes: an inconsistent manifest/freeze file cannot build
the new shell until resolved.

`index-state` in `cabal.project` limits available Hackage uploads and revisions.
The generated freeze file may record the last upload before that timestamp.
To advance the index, update the date and remove the old freeze file's
`index-state` line before regenerating. `cabal update` alone does not change
these pins. A new index date must also be available in the pinned haskell.nix
Hackage snapshot.

## Pin a library to Git

Use an immutable commit and fetch its content hash:

```sh
nix-prefetch-git https://github.com/haskell/mtl.git \
  37cbd924cb71eba591a2e2b6b131767f632d22c9
```

Then add this stanza to `cabal.project`, using the returned `sha256`:

```cabal
source-repository-package
  type: git
  location: https://github.com/haskell/mtl.git
  tag: 37cbd924cb71eba591a2e2b6b131767f632d22c9
  --sha256: 15vyrp3kkjmnsv4q01nr01710m01i6hnp0y6jb7mycl5bad7ggsr
```

This is an optional example; the default toolbox uses the released `mtl`.
The package must also appear in `build-depends`. For a monorepo, add `subdir:`
pointing to the package directory. Recompute the hash whenever changing the
commit, regenerate the freeze file, and rebuild. Git sources can have different
Cabal bounds than revised Hackage releases; resolve any solver conflict
explicitly rather than enabling a global `allow-newer`.

## What is pinned

- `../flake.lock` pins haskell.nix, its Nixpkgs, and Hackage metadata separately
  from the operating system's Nixpkgs.
- `default.nix` selects the compiler and Cabal; `hls.nix` pins HLS and contains
  its GHC 9.14 compatibility settings. Tool dependencies are resolved against
  the locked haskell.nix snapshot, separately from the script-library freeze.
- `cabal.project` pins the Hackage index and selected Git commits/content hashes.
- `cabal.project.freeze` records the library solution, including transitive
  versions and any selected package flags. Compiler-bundled libraries track GHC.

The Nix definition explicitly loads the freeze file and extracts a compiler
from `shellFor` with `exactDeps = true`. This exposes the resolved libraries
without adding conflicting GHC-bundled copies when you use a Git override.
The shell's restrictive `CABAL_CONFIG` is not exported, so ordinary Cabal
commands can still resolve new dependencies.

To update haskell.nix intentionally, change its explicit revision in the parent
`flake.nix`, run `nix flake update haskellNix --flake ~/nixos`, and review the lock
diff. Check HLS compatibility when changing GHC. Keep the compiler, libraries,
and HLS from this same haskell.nix package set.

Nix caches are configured in `modules/nix-developer-trust.nix`. Before the first
system activation, builds can use them explicitly:

```sh
nix build ~/nixos#haskell-toolbox \
  --extra-substituters 'https://cache.iog.io https://cache.zw3rk.com' \
  --extra-trusted-public-keys 'hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk='
```

Uncached tool or library versions may need substantial compilation. An
unsuccessful build leaves the installed system generation available.
