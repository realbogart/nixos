final: _prev: {
  chatgpt = final.callPackage ../packages/chatgpt/package.nix { };
  claude-code = final.callPackage ../packages/claude-code/package.nix { };
  codex = final.callPackage ../packages/codex/package.nix { };
}
