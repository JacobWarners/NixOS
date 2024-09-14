{ config, pkgs, ... }:

{
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "23.05"; # Adjust this to match your Home Manager version

  programs.zsh = {
    enable = true;
  };

  programs.vim.enable = true;
  programs.tmux.enable = true;

  # Install user-specific packages
  home.packages = with pkgs; [
    zsh       # Ensure Zsh is included in packages
    yazi
    # Add other user-specific packages here
  ];


#  # Link dotfiles
#  home.file.".zshrc".source = ./dotfiles/.zshrc;
#  home.file.".vimrc".source = ./dotfiles/.vimrc;
#  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
#
  # Ensure the .ssh directory exists with correct permissions
#  home.file.".ssh" = {
#    directory = true;
#    mode = "0700";
#  };

  # SSH key management
#  home.file.".ssh/id_ed25519" = {
#    source = ../secrets/ssh/id_ed25519;
#    mode = "0600";
#  };
#  home.file.".ssh/id_ed25519.pub" = {
#    source = ../secrets/ssh/id_ed25519.pub;
#    mode = "0644";
#  };
}

