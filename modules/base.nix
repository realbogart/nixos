{ config, pkgs, ... }:
{
  # Pin the Nix CLI to the latest version available in this nixpkgs.
  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
    trusted-users = [ "root" "johan" ];
    allow-import-from-derivation = true;
    accept-flake-config = true;
    secret-key-files = [ "/home/johan/.config/nix/cache-priv-key.pem" ];
  };

}
