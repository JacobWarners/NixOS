{ config, pkgs, ... }:

{
  home.username = "jake";
  home.homeDirectory = "/home/jake";

  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    interactiveShellInit = ''
      # Custom Zsh configurations can go here
    '';
  };

  programs.vim.enable = true;
  programs.tmux.enable = true;

  # Install user-specific packages
  home.packages = with pkgs; [
    yazi
    # Add other user-specific packages here
  ];

  # Link dotfiles
  home.file.".zshrc".source = ./dotfiles/.zshrc;
  home.file.".vimrc".source = ./dotfiles/.vimrc;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;

  # SSH key management
  home.file.".ssh/id_ed25519".source = ../secrets/ssh/id_ed25519;
  home.file.".ssh/id_ed25519.pub".source = ../secrets/ssh/id_ed25519.pub;

  # Ensure correct permissions
  home.file.".ssh/id_ed25519".permissions = "0600";
  home.file.".ssh/id_ed25519.pub".permissions = "0644";
}
