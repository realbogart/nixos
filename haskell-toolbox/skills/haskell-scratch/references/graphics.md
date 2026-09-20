# Graphical Haskell prototypes with live reload

Use this workflow for standalone h-raylib apps on Johan's Linux/XMonad
desktop. It uses the shared toolbox, ordinary `.hs` files, and ghcid; no
new Cabal project is needed. Preserve an existing application's build
environment when extending that application.

## Start a prototype

Copy the two files in [assets/raylib](../assets/raylib/) into a new directory
chosen for the prototype. For example, from a directory where `my-graphics`
does not already exist:

```sh
mkdir my-graphics
cp ~/.codex/skills/haskell-scratch/assets/raylib/RaylibWindow.hs my-graphics/
cp ~/.codex/skills/haskell-scratch/assets/raylib/watch-raylib.sh my-graphics/
cd my-graphics
bash ./watch-raylib.sh
```

Edit `drawFrame` in `RaylibWindow.hs` and save. Its `Double` argument is
elapsed seconds since window creation. Start with shapes, text, and input
handling appropriate to the requested app. The launcher selects the shared
toolbox and uses its own directory as the working directory, including for
relative asset paths. Keep the file name or update the launcher's command.

The command inside the launcher is:

```sh
nix develop ~/nixos#haskell-toolbox --command \
  ghcid --command='ghci -ignore-dot-ghci RaylibWindow.hs' --test=Main.mainDev --warnings
```

Run once without watching:

```sh
nix develop ~/nixos#haskell-toolbox --command runghc RaylibWindow.hs
```

Requires access to a graphical desktop (`DISPLAY` in the tested X11 setup).
The shared shell is also useful when the calling terminal inherited a
different project's GHC/package environment. No system activation is needed
to use an already built toolbox through `nix develop`.

## Why the window survives a reload

The starter follows the pattern in `~/projects/trmnl-livingroom/src/Main.hs`:

1. The first `mainDev` creates an `IORef (Double -> IO ())` and preserves it
   in `foreign-store`, which survives GHCi `:reload`.
2. A `forkOS` thread creates the window and owns all its raylib/OpenGL calls,
   including drawing, event polling, and shutdown.
3. Each frame reads the current callback from the `IORef`.
4. After successful compilation, ghcid calls `mainDev` again. It atomically
   installs the newly compiled `drawFrame` and returns immediately. The
   existing thread, window, and elapsed-time origin keep running.

`--test=main` instead reruns the ordinary startup/teardown path. For this
starter, use `--test=Main.mainDev`. The generic Neovim watcher shortcut may
target `main`; use the supplied launcher for this workflow unless the
shortcut has been configured for `mainDev`.

## What can change live

Drawing code and helpers invoked by the new callback can change live.
Compilation errors leave the last working callback running. A runtime
exception in the callback closes the window; the next successful reload
can create it again.

Window initialization and the persistent loop are captured by the running
thread. Restart the watcher to change them. `foreign-store` does not check
types: keep the `devStore` type and any stored data representation unchanged
across reloads. Restart before changing that contract. Slot 0 is reserved
for this starter in its GHCi process; use a separate process for another
independent prototype.

For app state that should survive edits, add an `IORef` to the persistent
session and pass its contents into the replaceable callback. Restart when
introducing or changing its representation. The sample preserves the
animation clock; it does not automatically persist arbitrary top-level
Haskell values.

Load fonts, textures, and other GPU resources once on the rendering thread,
keep their handles with the session, and release them on that thread before
closing the window. Avoid allocating them every frame. Keep raylib calls
out of the REPL-side reload branch; route updates through the callback or
an explicit command queue as the app grows.

Escape closes the window; saving a valid edit opens a fresh one. Ctrl-C
stops the watcher and its GHCi process. In a manual GHCi session, `stopDev`
requests shutdown on the rendering thread and waits for cleanup. Stop
agent-created test watchers when verification ends unless the user asked
to leave one running.

## Floating versus tiling

The starter creates a fixed-size 800×450 window. GLFW advertises matching
minimum and maximum sizes through X11 `WM_NORMAL_HINTS`, and XMonad floats
fixed-size windows automatically. No application-specific float rule is
needed. This was confirmed against the actual window hints.

To allow tiling/resizing, import `ConfigFlags (WindowResizable)` from
`Raylib.Types` and call this **before** `initWindow`:

```haskell
setConfigFlags [WindowResizable]
```

Adapt the drawing layout using `getScreenWidth` and `getScreenHeight`.
Restart the watcher after changing initialization. Other window managers
may handle these hints differently.

## Verify a prototype

Typecheck with the selected toolbox, then exercise the actual window:

```sh
nix develop ~/nixos#haskell-toolbox --command \
  ghc -Wall -Werror -fno-code -fforce-recomp RaylibWindow.hs
```

The starter accepts `--smoke-test`: it writes `raylib-smoke.png` in the
working directory and exits after three seconds. Run it from a unique
temporary directory with an absolute script path. Inspect the resulting
image as well as checking the process exit status.

When changing the reload machinery, test on a disposable copy: record the
window ID with `xdotool search --name`, temporarily change the title from
the drawing callback using `setWindowTitle`, and verify the same ID gets
the new title. Include elapsed seconds in the title to confirm the clock
did not reset. Introduce and fix a compile error to verify that the previous
callback stays active and subsequent reloads recover. Do not alter a user's
active prototype for this check.

## Toolbox details

The tested setup uses GHC 9.14.1, h-raylib 6.1.0.0, and foreign-store 0.2.1.
Inspect the active package database for current versions. The toolbox pins
h-raylib with `+ghci +disable-lens`; optional lens helpers are not available.
Its Nix definition supplies native libc, OpenGL, and X11 dependencies for
the bundled raylib/GLFW build. Preserve that native-library mapping,
`exactDeps = true`, and existing freeze-file versions and flags when making
authorized dependency changes. See `~/nixos/haskell-toolbox/README.md` for
the dependency maintenance procedure.
