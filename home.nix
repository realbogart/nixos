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

  programs.git = {
    enable = true;
    userName = "Johan Yngman";
    userEmail = "johan.yngman@gmail.com";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

# ln -s $SCRIPTPATH/.bashrc ~/.bashrc
# ln -s $SCRIPTPATH/.zshrc ~/.zshrc
# ln -s $SCRIPTPATH/nvim ~/.config
# ln -s $SCRIPTPATH/nvim/.vimrc ~/.vimrc
# ln -s $SCRIPTPATH/tmux ~/.config
# ln -s $SCRIPTPATH/starship.toml ~/.config
# ln -s $SCRIPTPATH/git ~/.config

  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
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
