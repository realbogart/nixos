{ config, pkgs, ... }:
{
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

  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "nodeadkeys";
  };

  console.keyMap = "sv-latin1";
}
