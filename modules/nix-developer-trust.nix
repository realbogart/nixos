{ ... }:
{
  nix.settings = {
    extra-substituters = [
      "https://cache.iog.io"
      "https://cache.zw3rk.com"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];
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
