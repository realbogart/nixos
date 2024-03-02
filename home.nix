configName:
{ config, pkgs, ... }: {
  home.username = "johan";
  home.homeDirectory = "/home/johan";

  home.packages = with pkgs; [
    zip
    unzip
    ripgrep
    fzf
    clang
    gnumake
    tmux
    nil
    xsel
    syncthing
    nixfmt
    stylua
    s3cmd
    gnupg
    fdupes
  ];

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
    syntaxHighlighting.enable = true;

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
      {
        name = "zsh-vi-mode";
        src = pkgs.fetchFromGitHub {
          owner = "jeffreytse";
          repo = "zsh-vi-mode";
          rev = "v0.11.0";
          sha256 = "sha256-xbchXJTFWeABTwq6h4KWLh+EvydDrDzcY9AQVK65RS8=";
        };
      }
    ];

    initExtra = ''
      export ZVM_VI_INSERT_ESCAPE_BINDKEY="kj"
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      zstyle ':bracketed-paste-magic' active-widgets '.self-*'
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

    ".vimrc".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/nvim/vimrc.vim";
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/nvim";
    ".config/tmux".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/tmux";
    ".config/git".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/git";
    ".config/alacritty".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/alacritty";
    ".config/startship.toml".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/starship.toml";
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

