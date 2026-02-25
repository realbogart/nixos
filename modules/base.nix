{ config, pkgs, ... }:
{
  nix.settings.trusted-users = [ "root" "johan" ];
  nix.settings.secret-key-files =
    [ "/home/johan/.config/nix/cache-priv-key.pem" ];

}
