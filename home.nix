{ config, pkgs, ... }:

{
  home.username = "johan";
  home.homeDirectory = "/home/johan";

  home.packages = with pkgs; [
    zip
    unzip
    ripgrep
    fzf
  ];

  programs.git = {
    enable = true;
    userName = "Johan Yngman";
    userEmail = "johan.yngman@gmail.com";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
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

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
