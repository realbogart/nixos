{ pkgs, ... }:
{
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "org.mozilla.firefox"
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
}
