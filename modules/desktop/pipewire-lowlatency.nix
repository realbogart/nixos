{ ... }:
{
  services.pulseaudio.enable = false;
  musnix.enable = true;
  musnix.rtcqs.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig = {
      pipewire."10-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 64;
          "default.clock.max-quantum" = 256;
        };
      };
    };
    wireplumber.extraConfig = {
      "20-disable-non-ucx-audio" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "alsa.id" = "NVidia";
              }
              {
                "device.name" = "alsa_card.pci-0000_01_00.1";
              }
            ];
            actions = {
              update-props = {
                "device.disabled" = true;
              };
            };
          }
        ];
      };
    };
  };

  systemd.user.services.pipewire.serviceConfig = {
    Nice = -11;
    LimitRTPRIO = 95;
    LimitMEMLOCK = "infinity";
  };

  systemd.user.services.pipewire-pulse.serviceConfig = {
    Nice = -11;
    LimitRTPRIO = 95;
    LimitMEMLOCK = "infinity";
  };

  systemd.user.services.wireplumber.serviceConfig = {
    Nice = -11;
    LimitRTPRIO = 95;
    LimitMEMLOCK = "infinity";
  };
}
