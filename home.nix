{ config, pkgs, ... }:

let
  nvimConfig = pkgs.fetchFromGitHub {
    owner = "realbogart";
    repo = "nvim";
    rev = "aeddf23b37cf919ac6a7b36e865d9cd626cb040c";
    sha256 = "0jqvfpvzp4jyzskvyl3jnkmwxdrn16ym5ram1bbblxar8ywnjhkb";
  };
in
{
  home.username = "johan";
  home.homeDirectory = "/home/johan";

  home.packages = with pkgs; [
    zip
    unzip
    ripgrep
    fzf
    clang
    gnumake
  ];

  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zsh-autosuggestions" "zsh-vi-mode" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake /etc/nixos#default";
    };
  };

  home.file = {
    ".bashrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.bashrc";
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.zshrc";
    ".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim/vimrc.vim";
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    ".config/tmux".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/tmux";
    ".config/git".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/git";
    ".config/startship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/starship.toml";
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

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
