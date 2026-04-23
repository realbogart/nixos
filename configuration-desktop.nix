{
  config,
  lib,
  pkgs,
  ...
}:

let
  vaultShares = [
    "backup"
    "media"
    "music_backup"
    "PlexMediaServer"
    "temp"
  ];

  vaultMountOptions = [
    "noauto"
    "x-systemd.automount"
    "x-systemd.idle-timeout=10min"
    "x-systemd.mount-timeout=30s"
    "rw"
    "vers=3"
  ];

  mkVaultMount = share: {
    name = "/mnt/vault/${share}";
    value = {
      device = "vault.local:/volume1/${share}";
      fsType = "nfs";
      options = vaultMountOptions;
    };
  };
in
{
  imports = [
    ./hardware-configuration-desktop.nix
  ];

  nix.settings = {
    extra-trusted-public-keys = [
      # Binary Cache for Haskell.nix
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="

      # My binary cache
      "nix-cache-1:5Fn/+OJmth/6OjD6S59pptotG6pFp8fM/LOCzrr+sGg="
    ];
    extra-substituters = [
      "https://cache.iog.io"
      "https://nix-cache.ams3.digitaloceanspaces.com"
    ];
  };

  virtualisation.docker.daemon.settings = {
    insecure-registries = [ "10.0.1.12:30500" ];
  };
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.libvirtd.enable = true;

  # Re-enable this with libvirtd if you want to restore libvirt later.
  # Upstream unit currently hardcodes /usr/bin/sh, which does not exist on NixOS.
  # systemd.services."virt-secret-init-encryption".serviceConfig.ExecStart = lib.mkForce [
  #   ""
  #   "${pkgs.runtimeShell} -c 'umask 0077 && (${pkgs.coreutils}/bin/dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
  # ];

  # users.extraGroups.vboxusers.members = [ "johan" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # 95 MB ESP is very small; keep only one generation to avoid boot entry copy failures.
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.kernelParams = [ "threadirqs" ];
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.roboto-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts._0xproto
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "FiraMono Nerd Font Mono" ];
  };

  # Graphics setup
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia = {
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.modemmanager.enable = false;
  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.unmanaged = [ "type:wifi" ];

  services.flatpak.enable = true;
  services.flatpak.packages = [
    "org.mozilla.firefox"
    "com.brave.Browser"
    "com.spotify.Client"
    "com.discordapp.Discord"
    "im.riot.Riot"
    "org.signal.Signal"
    "com.rtosta.zapzap"
  ];
  services.flatpak.update.onActivation = false;
  services.flatpak.uninstallUnmanaged = true;
  services.flatpak.overrides = {
    "com.discordapp.Discord".Context = {
      devices = [ "all" ];
      shared = [
        "ipc"
        "network"
      ];
      sockets = [
        "pulseaudio"
        "x11"
      ];
    };
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-xapp
    ];
    config = {
      common.default = [
        "gtk"
        "xapp"
      ];
      "none+xmonad".default = [
        "gtk"
        "xapp"
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.sessionCommands = ''
    export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${config.system.path}/share:''${XDG_DATA_DIRS:-}"
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd XDG_DATA_DIRS || true
    ${pkgs.picom}/bin/picom --config /home/johan/.config/picom/picom.conf &
  '';
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "johan";
  services.xserver.windowManager.xmonad.enable = true;
  services.xserver.windowManager.xmonad.enableContribAndExtras = true;
  programs.slock.enable = true;
  security.polkit.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Enable sound with pipewire.
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
    # If you want to use JACK applications, uncomment this
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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.johan = {
    isNormalUser = true;
    description = "Johan Yngman";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev"
      "audio"
      "ubridge"
      # "qemu-libvirtd"
      # "libvirtd"
    ];

    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcWjSPo+Zu7PKsjPjnTqs7JsUUN3cjs8omPv7DklJbnwKnveAT8TpPlIZE996CptgbJ4AO8rWgiFhxSOrb+KQS4Aej7FQMj9gAcOwPZkdhTAoU2XbYnpFs5roId3+l+mNV/I3oGWCNfOcO4P2OaSXORkk2Gr2mc2lNJAYaWNrkOk68IDZiWjHMbA/JYZMzGSKTyytOAWyVvN1hs5YPrPektyT+r/YbVPxOYrQnK9udBC6/xMt2pvjpdUtnwXsRYBaCXVNQKm9ptASSBA1sVsYByf2KZRaQgV+E7lT9tqwvYlKbVvIcdnvW303GHNl7mAaVb5MtQ67v6TG4CPOK4GJJIJKjsXQYHE8HUioGgZx00OCw7iRJ3WwEKh0VV6FpYiKPVXHSgZSql2e+EXDB7gxK0OC6gdNDGZvLP9OhUWFZBlWm/vFAivsfLWgPT2ARurso7oIntkprwnNwt4XI4khYIFggjEPjHzw3Q+C/ZgqVg9OcaZ8AOMANJ9X/O1F9NjnnXGfLbyvuDAdkjO8zwESaieUZ8jbZqBWdwL3q1IiYAUn9ibKZlRP6pG7ECUSAPVyrDCllfCvLRMSCOdge8xNKYZ0ugE2JPw4c2wyViN0ZIHISmBLDDl0/yADBE+e2yubCbND9J7kL8BkQwyduv7cbR+T06IataZIxn9doPiFD1w== johan@nixos"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    taffybar
    xmobar
    xterm
    wget
    qjackctl
    lm_sensors
    nfs-utils
    qemu
    usbutils
    pciutils
    # nvidia-offload

    # Desktop apps
    wineWow64Packages.stable
    steam
  ];

  fileSystems = builtins.listToAttrs (map mkVaultMount vaultShares);

  systemd.tmpfiles.rules = [
    "d /mnt/vault 0775 johan users - -"
  ]
  ++ map (share: "d /mnt/vault/${share} 0775 johan users - -") vaultShares;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.cron.enable = true;
  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
      # Rule for all ZSA keyboards
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
      # Rule for the Ergodox EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
      # Rule for the Planck EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = false;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # security.wrappers.ubridge = {
  #   source = "/run/wrappers/bin/ubridge";
  #   capabilities = "cap_net_admin,cap_net_raw=ep";
  #   owner = "root";
  #   group = "ubridge";
  #   # permissions = "u+rx,g+x";
  #   permissions = "u+rx,g+rx,o+rx";
  # };

  # services.gns3-server.ubridge.enable = true;
  # services.gns3-server.enable = true;
  # services.gns3-server.settings = {
  #   Server.ubridge_path = pkgs.lib.mkForce "/run/wrappers/bin/ubridge";
  # };
  # users.groups.gns3 = { };
  # users.groups.ubridge = { };
  # users.users.gns3 = {
  #   group = "gns3";
  #   isSystemUser = true;
  # };
  # systemd.services.gns3-server.serviceConfig = {
  #   User = "gns3";
  #   DynamicUser = pkgs.lib.mkForce false;
  #   NoNewPrivileges = pkgs.lib.mkForce false;
  #   RestrictSUIDSGID = pkgs.lib.mkForce false;
  #   PrivateUsers = pkgs.lib.mkForce false;
  #   # ExecStart = "${lib.getExe cfg.package} ${commandArgs}";
  #   DeviceAllow = [ "/dev/net/tun rw" "/dev/net/tap rw" ]
  #     ++ pkgs.lib.optionals config.virtualisation.libvirtd.enable
  #     [ "/dev/kvm" ];
  # };

  networking.firewall = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
