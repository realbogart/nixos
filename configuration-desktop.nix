{ ... }:

{
  imports = [
    ./hardware-configuration-desktop.nix
    ./modules/desktop/common.nix
    ./modules/desktop/flatpak.nix
    ./modules/desktop/nvidia.nix
    ./modules/desktop/pipewire-lowlatency.nix
    ./modules/desktop/users.nix
    ./modules/desktop/vault-nfs.nix
    ./modules/desktop/xmonad.nix
  ];

  # 95 MB ESP is very small; keep only one generation to avoid boot entry copy failures.
  boot.loader.systemd-boot.configurationLimit = 1;

  networking.hostName = "nixos";

  services.flatpak.packages = [
    "com.brave.Browser"
  ];

  system.stateVersion = "23.11";
}
