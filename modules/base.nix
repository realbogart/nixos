{ config, pkgs, ... }:
{
  # Pin the Nix CLI to the latest version available in this nixpkgs.
  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;

  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  # Trust the private VPN CA system-wide.
  security.pki.certificateFiles = [
    ../certs/kamel-internal-ca.pem
  ];
}
