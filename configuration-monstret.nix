{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration-monstret.nix
    ./modules/desktop/common.nix
    ./modules/desktop/flatpak.nix
    ./modules/desktop/nvidia.nix
    ./modules/desktop/pipewire-lowlatency.nix
    ./modules/desktop/users.nix
    ./modules/desktop/vault-nfs.nix
    ./modules/desktop/xmonad.nix
  ];

  # Keep a few fallback generations available in the boot menu.
  boot.loader.systemd-boot.configurationLimit = 5;

  networking.hostName = "monstret";

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  services.pipewire.wireplumber.extraConfig = {
    "30-prefer-fireface-line-out" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "alsa_output.usb-RME_Fireface_UCX__23973113__85BF2733A2CE3C8-00.HiFi__Line5__sink";
            }
          ];
          actions = {
            update-props = {
              "priority.session" = 1500;
            };
          };
        }
        {
          matches = [
            {
              "node.name" = "alsa_output.usb-RME_Fireface_UCX__23973113__85BF2733A2CE3C8-00.HiFi__SPDIF2__sink";
            }
          ];
          actions = {
            update-props = {
              "priority.session" = 100;
            };
          };
        }
      ];
    };
  };

  systemd.user.services.pipewire-default-fireface-lineout = {
    description = "Select Fireface line output as the default PipeWire sink";
    after = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        ""
        "${pkgs.bash}/bin/bash -lc 'for _ in $(seq 1 20); do ${pkgs.wireplumber}/bin/wpctl status >/dev/null 2>&1 && break; sleep 1; done; ${pkgs.wireplumber}/bin/wpctl set-default alsa_output.usb-RME_Fireface_UCX__23973113__85BF2733A2CE3C8-00.HiFi__Line5__sink; ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0'"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];

  system.stateVersion = "23.11";
}
