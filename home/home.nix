{ config, pkgs, ... }:

{
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "23.05"; # Adjust this to match your Home Manager version

  #ZSH
  programs.zsh = {
    enable = true;
  };

  #TMUX and VIM
  programs.tmux.enable = true;

  # Install user-specific packages
  home.packages = with pkgs; [
    zsh       # Ensure Zsh is included in packages
    yazi 
    # Add other user-specific packages here
  ];

  #Hyprland

#  wayland.windowManager.hyprland = {
#    enable = true;
#    package = pkgs.hyprland;
#  };


  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox
    ];
    extraConfig = ''
      " Adds syntax highlighting
      syntax on

      " Color scheme
      colorscheme gruvbox
      set background=dark

      " Enable line numbers
      set number

      " Set cursorline
      set cursorline

      " Show matching parentheses
      set showmatch

      " Toggle paste with F2
      set paste
      set pastetoggle=<F2>

      " Enable mouse support
      set mouse=a

      " Custom keybinding to exit directory with Q
      nnoremap Q :Rexplore<CR>
    '';
  };



  # Link dotfiles
  home.file.".zshrc".source = ./dotfiles/.zshrc;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".config/hypr/hyprland.conf".source = ./hyprland/hyprland.conf;
#  home.file.".config/hypr/start.sh".source = ./hyprland/start.sh;


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

