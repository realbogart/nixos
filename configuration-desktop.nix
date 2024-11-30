{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration-desktop.nix modules/syncthing.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  # Binary Cache for Haskell.nix
  nix.settings.trusted-public-keys =
    [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  nix.settings.substituters = [ "https://cache.iog.io" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Graphics setup
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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
      "qemu-libvirtd"
      "libvirtd"
    ];

    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcWjSPo+Zu7PKsjPjnTqs7JsUUN3cjs8omPv7DklJbnwKnveAT8TpPlIZE996CptgbJ4AO8rWgiFhxSOrb+KQS4Aej7FQMj9gAcOwPZkdhTAoU2XbYnpFs5roId3+l+mNV/I3oGWCNfOcO4P2OaSXORkk2Gr2mc2lNJAYaWNrkOk68IDZiWjHMbA/JYZMzGSKTyytOAWyVvN1hs5YPrPektyT+r/YbVPxOYrQnK9udBC6/xMt2pvjpdUtnwXsRYBaCXVNQKm9ptASSBA1sVsYByf2KZRaQgV+E7lT9tqwvYlKbVvIcdnvW303GHNl7mAaVb5MtQ67v6TG4CPOK4GJJIJKjsXQYHE8HUioGgZx00OCw7iRJ3WwEKh0VV6FpYiKPVXHSgZSql2e+EXDB7gxK0OC6gdNDGZvLP9OhUWFZBlWm/vFAivsfLWgPT2ARurso7oIntkprwnNwt4XI4khYIFggjEPjHzw3Q+C/ZgqVg9OcaZ8AOMANJ9X/O1F9NjnnXGfLbyvuDAdkjO8zwESaieUZ8jbZqBWdwL3q1IiYAUn9ibKZlRP6pG7ECUSAPVyrDCllfCvLRMSCOdge8xNKYZ0ugE2JPw4c2wyViN0ZIHISmBLDDl0/yADBE+e2yubCbND9J7kL8BkQwyduv7cbR+T06IataZIxn9doPiFD1w== johan@nixos"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    wget
    qjackctl
    lm_sensors
    nfs-utils
    qemu
    # nvidia-offload

    # Desktop apps
    brave
    firefox
    discord
    flameshot
    spotify
    wine
    # vagrant
    steam
  ];

  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  fileSystems."/mnt/vault/backup" = {
    device = "192.168.10.253:/volume1/backup";
    fsType = "nfs";
    options = [ "rw" "vers=3" ];
  };

  fileSystems."/mnt/vault/media" = {
    device = "192.168.10.253:/volume1/media";
    fsType = "nfs";
    options = [ "rw" "vers=3" ];
  };

  fileSystems."/mnt/vault/music_backup" = {
    device = "192.168.10.253:/volume1/music_backup";
    fsType = "nfs";
    options = [ "rw" "vers=3" ];
  };

  fileSystems."/mnt/vault/PlexMediaServer" = {
    device = "192.168.10.253:/volume1/PlexMediaServer";
    fsType = "nfs";
    options = [ "rw" "vers=3" ];
  };

  fileSystems."/mnt/vault/temp" = {
    device = "192.168.10.253:/volume1/temp";
    fsType = "nfs";
    options = [ "rw" "vers=3" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/vault 0775 johan users - -"
    "d /mnt/vault/backup 0775 johan users - -"
    "d /mnt/vault/music_backup 0775 johan users - -"
    "d /mnt/vault/PlexMediaServer 0775 johan users - -"
    "d /mnt/vault/temp 0775 johan users - -"
  ];

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

  # services.nfs.client.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
