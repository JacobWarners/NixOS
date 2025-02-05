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
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      bind-key S setw synchronize-panes

    '';
  };

  # Install user-specific packages
  home.packages = with pkgs; [
    zsh # Ensure Zsh is included in packages
    yazi
    # Add other user-specific packages here
  ];

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
      set pastetoggle=<F2>

      " Enable mouse support
      set mouse=a

      " Custom keybinding to exit directory with Q
      nnoremap Q :Rexplore<CR>
      inoremap jj <Esc>
    '';
  };

    home.sessionVariables = {
      PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
            };


  # Link dotfiles
  home.file.".zshrc".source = ./dotfiles/.zshrc;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".config/kitty".source = ./kitty;
  home.file.".icons".source = ./dotfiles/.icons;
}
