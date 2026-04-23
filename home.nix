{
  configName,
  nix-yaml,
  nix-azure-pipelines-language-server,
  pkgs-realbogart,
}:
{ config, pkgs, ... }:
let
  browserDesktop = "brave-browser.desktop";
in
{
  home.username = "johan";
  home.homeDirectory = "/home/johan";

  home.packages = with pkgs; [
    git
    git-lfs
    zip
    unzip
    ripgrep
    fzf
    btop
    clang
    gnumake
    tmux
    rofi
    picom
    hsetroot
    xdotool
    gsimplecal
    nil
    vlc
    xsel
    xbanish
    dunst
    libnotify
    lxqt.lxqt-policykit
    xss-lock
    nixfmt
    stylua
    s3cmd
    gnupg
    fdupes
    rclone
    prettierd
    pkg-config
    file
    hwinfo
    lshw
    tree
    magic-wormhole
    docker
    helvum
    yaml-language-server
    wget
    pinta
    gimp
    gemini-cli
    unrar
    nix-prefetch-scripts
    runc
    containerd
    grpcurl
    wireguard-tools
    gh
    flameshot
    copyq
    brave
    pkgs-realbogart.neovim
    pkgs-realbogart.tree-sitter
    pkgs-realbogart.codex
    pkgs-realbogart.claude-code
    pkgs-realbogart.github-copilot-cli
    nix-yaml.packages.${pkgs.stdenv.hostPlatform.system}.yaml
    nix-azure-pipelines-language-server.packages.${pkgs.stdenv.hostPlatform.system}.azure-pipelines-language-server
  ];

  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
    ];

    initContent = ''
      export EDITOR=nvim
      export ZVM_VI_INSERT_ESCAPE_BINDKEY="kj"
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      zstyle ':bracketed-paste-magic' active-widgets '.self-*'
      bindkey '\C-e' edit-command-line
      bindkey '^H' backward-delete-char
      bindkey '^?' backward-delete-char
      echo '\e[5 q'

      # Skip auto-tmux on Linux virtual consoles.
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [[ ! "$TTY" =~ ^/dev/tty[0-9]+$ ]]; then
        exec tmux
      fi

      update() {
        local flake_target="$HOME/nixos#${configName}"
        local log_file="/tmp/nixos-update-${configName}.log"

        printf 'update debug: hostname=%s\n' "$(hostname)"
        printf 'update debug: configName=%s\n' "${configName}"
        printf 'update debug: flake target=%s\n' "$flake_target"
        printf 'update debug: log file=%s\n' "$log_file"

        sudo nixos-rebuild switch --flake "$flake_target" --show-trace 2>&1 | tee "$log_file"
      }
    '';

    shellAliases = {
      ll = "ls -l";
    };
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = browserDesktop;
        "application/xhtml+xml" = browserDesktop;
        "x-scheme-handler/http" = browserDesktop;
        "x-scheme-handler/https" = browserDesktop;
        "x-scheme-handler/about" = browserDesktop;
        "x-scheme-handler/unknown" = browserDesktop;
      };
    };
  };

  home.file = {
    ".tmux/plugins/tpm".source = builtins.fetchGit {
      url = "https://github.com/tmux-plugins/tpm.git";
      rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
    };

    ".vimrc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim/vimrc.vim";
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    ".config/tmux".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/tmux";
    ".config/git".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/git";
    ".config/alacritty".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/alacritty";
    ".config/rofi".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi";
    ".config/picom/picom.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/picom/picom.conf";
    ".config/gsimplecal/config".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/gsimplecal/config";
    ".config/dunst/dunstrc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dunst/dunstrc";
    ".config/xmonad/launcher-apps.tsv".text = ''
      # Label<TAB>Command<TAB>Icon
      # :setlocal noexpandtab
      Terminal: Alacritty	alacritty	Alacritty
      btop	alacritty --class btop,btop -e sh -lc "btop"	Alacritty
      Brave	brave	brave-browser
      Firefox	flatpak run org.mozilla.firefox	org.mozilla.firefox
      Discord	flatpak run com.discordapp.Discord	com.discordapp.Discord
      Signal	flatpak run org.signal.Signal	org.signal.Signal
      Element	flatpak run im.riot.Riot	im.riot.Riot
      Spotify	flatpak run com.spotify.Client	com.spotify.Client
      WhatsApp	flatpak run com.rtosta.zapzap	com.rtosta.zapzap
      Flatpak: Update all	alacritty -e sh -lc "flatpak update -y; printf '\nPress Enter to close...'; read -r _"	flatpak-update
      Flatpak: List installed	alacritty -e sh -lc "flatpak list; printf '\nPress Enter to close...'; read -r _"	flatpak-list
      REAPER	sh -lc "cd /home/johan/music/reaper-env && nohup direnv exec . ./scripts/run-reaper >/dev/null 2>&1 &"	audio-x-generic
    '';
    ".xmonad/xmonad.hs".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/xmonad/xmonad.hs";
    ".local/bin/rofi-launcher".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/xmonad/rofi-launcher";
    ".xinitrc".text = ''
      export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:''${XDG_DATA_DIRS:-/run/current-system/sw/share:$HOME/.nix-profile/share:/usr/local/share:/usr/share}"
      exec /run/current-system/sw/bin/dbus-run-session ${pkgs.runtimeShell} -lc '
        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd XDG_DATA_DIRS || true
        ${pkgs.picom}/bin/picom --config "$HOME/.config/picom/picom.conf" &
        exec /run/current-system/sw/bin/xmonad
      '
    '';
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
