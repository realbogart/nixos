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
