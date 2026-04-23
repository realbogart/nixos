{ ... }:
{
  nix.settings = {
    trusted-users = [
      "root"
      "johan"
    ];
    allow-import-from-derivation = true;
    # Ensure IFD stays enabled even if pure-eval is set elsewhere.
    pure-eval = false;
    accept-flake-config = true;
  };
}
