{
  configName,
  nix-yaml,
  nix-azure-pipelines-language-server,
  pkgs-realbogart,
}:
{ config, pkgs, ... }:
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
    xdotool
    nil
    vlc
    xsel
    xbanish
    dunst
    libnotify
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
    neovim
    flameshot
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

      # Auto-start X only on tty1 so boot lands in xmonad.
      # Keep tty2/tty3/etc. as manual recovery consoles.
      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "''${XDG_VTNR:-}" = "1" ]; then
        exec startx
      fi

      # startx needs a real Linux VT; skip auto-tmux on /dev/ttyN consoles.
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [[ ! "$TTY" =~ ^/dev/tty[0-9]+$ ]]; then
        exec tmux
      fi
    '';

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/nixos#${configName}";
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
    ".config/dunst/dunstrc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dunst/dunstrc";
    ".config/xmonad/launcher-apps.tsv".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/xmonad/launcher-apps.tsv";
    ".xmonad/xmonad.hs".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/xmonad/xmonad.hs";
    ".local/bin/rofi-launcher".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/xmonad/rofi-launcher";
    ".xinitrc".text = ''
      export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:''${XDG_DATA_DIRS:-/run/current-system/sw/share:$HOME/.nix-profile/share:/usr/local/share:/usr/share}"
      exec /run/current-system/sw/bin/dbus-run-session ${pkgs.runtimeShell} -lc '
        ${pkgs.xorg.xset}/bin/xset s 600 5
        ${pkgs.xorg.xset}/bin/xset +dpms
        ${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- /run/wrappers/bin/slock &
        ${pkgs.dunst}/bin/dunst &
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
