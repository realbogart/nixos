{ config, pkgs, ... }:
{
  # Pin the Nix CLI to the latest version available in this nixpkgs.
  nix.package = pkgs.nixVersions.latest;
  nix.settings.trusted-users = [ "root" "johan" ];
  nix.settings.allow-import-from-derivation = true;
  nix.settings.accept-flake-config = true;
  nix.settings.secret-key-files =
    [ "/home/johan/.config/nix/cache-priv-key.pem" ];

}
