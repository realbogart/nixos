{ config, lib, pkgs, ... }:

{
  imports = [ ];

  wsl = {
    enable = true;
    defaultUser = "johan";
    useWindowsDriver = true;
    wslConf.interop.appendWindowsPath = false;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  users.users.johan.extraGroups = [ "docker" ];
  virtualisation.docker.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  services.jack = {
    jackd.enable = true;
    # support ALSA only programs via ALSA JACK PCM plugin
    alsa.enable = false;
    # support ALSA only programs via loopback device (supports programs like Steam)
    loopback = {
      enable = true;
      # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
      #dmixConfig = ''
      #  period_size 2048
      #'';
    };
  };

  users.extraUsers.johan.extraGroups = [ "jackaudio" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
