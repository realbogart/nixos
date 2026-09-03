final: _prev: {
  claude-code = final.callPackage ../packages/claude-code/package.nix { };
  codex = final.callPackage ../packages/codex/package.nix { };
}
