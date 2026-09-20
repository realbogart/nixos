{ pkgs }:
let
  compiler = "ghc9141";
  project = pkgs.haskell-nix.cabalProject' {
    src = pkgs.haskell-nix.haskellLib.cleanGit {
      name = "haskell-toolbox";
      src = ./.;
    };
    compiler-nix-name = compiler;
    # Current haskell.nix deliberately does not auto-load this file.
    cabalProjectFreeze = builtins.readFile ./cabal.project.freeze;
    modules = [
      {
        # h-raylib bundles raylib/GLFW; map its Linux linker dependencies
        # explicitly (haskell.nix has no mapping for libc's "c", "m", etc.).
        packages.h-raylib.components.library.libs = pkgs.lib.mkForce [
          pkgs.glibc
          pkgs.libGL
          pkgs.libx11
          pkgs.libxinerama
          pkgs.libxcursor
          pkgs.libxrandr
          pkgs.libxi
        ];
      }
    ];
  };
  # ghcWithPackages includes every GHC-bundled library. That makes a Git
  # replacement of e.g. mtl ambiguous. Expose only the solved dependency set.
  # Extracting .ghc also avoids exporting shellFor's CABAL_CONFIG globally.
  ghc =
    (project.shellFor {
      packages = _: [ ];
      additional = p: [ p.haskell-toolbox ];
      exactDeps = true;
      withHoogle = false;
    }).ghc;
  hls = pkgs.haskell-nix.tool compiler "haskell-language-server" (import ./hls.nix);
  cabal = pkgs.haskell-nix.tool compiler "cabal" { version = "3.16.1.0"; };
  package = pkgs.symlinkJoin {
    name = "haskell-toolbox-ghc-9.14.1";
    paths = [
      ghc
      hls
      cabal
      pkgs.ormolu
      pkgs.ghcid
    ];
  };
in
{
  inherit package project;
  shell = pkgs.mkShell {
    packages = [
      package
      pkgs.nix-prefetch-git
    ];
  };
}
