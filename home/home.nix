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
  XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:/run/current-system/sw/share:/usr/local/share:/usr/share";
};
home.sessionVariables = {
};
programs.zsh.initContent = ''
'';


  # --- START OF HYPRLAND HOME MANAGER CONFIGURATION ---
  wayland.windowManager.hyprland = {
    enable = true;
    # Ensure this package points to the correct Hyprland.
    # If using the flake input, `pkgs.hyprland` should resolve correctly
    # provided your flake setup imports it or the nixpkgs channel is up-to-date.
    package = pkgs.hyprland;
  };

  home.sessionVariables = {
    # This sets the path to your Hyprland configuration file.
    # You MUST have a `hyprland.conf` at this location.
    HYPRLAND_CONFIG_PATH = "${config.home.homeDirectory}/.config/hypr/hyprland.conf";
    # Your existing PATH modification
    PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
    # Your existing XDG_DATA_DIRS
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:/run/current-system/sw/share:/usr/local/share:/usr/share";
    # Your existing BROWSER variable
    BROWSER = "librewolf";
  };
  # --- END OF HYPRLAND HOME MANAGER CONFIGURATION ---

#Flatpak
xdg.enable = true;
  

  # Link dotfiles
  home.file.".zshrc".source = ./dotfiles/.zshrc;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".config/kitty".source = ./kitty;
  home.file.".icons".source = ./dotfiles/.icons;
}
