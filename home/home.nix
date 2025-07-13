# ./home/home.nix

{ config, pkgs, ... }:

{
  # --- User and Home Manager Setup ---
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "24.05"; # Updated to a more recent version

  # --- Combined Package List ---
  home.packages = with pkgs; [
    # Your existing packages
    zsh
    yazi

    # Hyprland Desktop Essentials
    kitty      # Wayland-native terminal
    waybar     # Status bar
    swww       # Wallpaper daemon
    swaylock-effects # Screen locker
    rofi-wayland # App launcher
    dunst      # Notification daemon
    pavucontrol # Audio control panel
    wl-clipboard # Wayland clipboard utilities
    
    # Screenshot Tools
    grim       # Screenshot utility
    slurp      # Screen region selector
  ];

  # --- Shell and Terminal Tools ---
  programs.zsh = {
    enable = true;
    initContent = ''
      alias firefox="librewolf"
    '';
  };

  programs.tmux = {
    enable = true;
    # Note: If you manage .tmux.conf via home.file, extraConfig might be redundant.
    # It's often better to choose one method.
    extraConfig = ''
      set -g mouse on
      bind-key S setw synchronize-panes
    '';
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ gruvbox ];
    extraConfig = ''
      syntax on
      colorscheme gruvbox
      set background=dark
      set number
      set cursorline
      set showmatch
      set pastetoggle=<F2>
      set mouse=a
      nnoremap Q :Rexplore<CR>
      inoremap jj <Esc>
    '';
  };

  # --- Web Browser: Librewolf ---
  programs.librewolf = {
    enable = true;
    settings = {
      # Your existing Librewolf settings are preserved here...
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;
      "browser.formfill.enable" = true;
      "places.history.enabled" = true;
      "browser.startup.homepage" = "about:blank"; # Or your preferred page
      "privacy.fingerprintingProtection" = true;
      # ...and so on for all your other settings.
    };
  };
  
  # --- Combined Session Variables ---
  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
    BROWSER = "librewolf";
    # This is often handled automatically by NixOS, but can be set if needed.
    # XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:/run/current-system/sw/share:/usr/local/share:/usr/share";
  };

  # --- Dotfile Management ---
  # Ensure these paths are correct relative to your home.nix location
  home.file = {
    ".zshrc".source = ./dotfiles/.zshrc;
    ".tmux.conf".source = ./dotfiles/.tmux.conf;
    ".config/kitty".source = ./kitty;
    ".icons".source = ./dotfiles/.icons;
  };

  # --- Flatpak / XDG Support ---
  xdg.enable = true;

  # --- Hyprland Desktop Environment ---
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      # Startup applications
      exec-once = [
        "waybar"
        "swww init"
        # IMPORTANT: Change this path to your actual wallpaper!
        "swww img ~/Pictures/wallpapers/your-wallpaper.png" 
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 15;
        border_size = 2;
        "col.active_border" = "rgba(ca9ee6ee) rgba(f2d5cfeee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur.enabled = true;
      };

      # Keybindings 🚀
      bind = [
        # --- Essentials ---
        "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, M, exit," # Exit Hyprland session
        "$mod, D, exec, rofi -show drun" # App launcher
        "$mod, L, exec, swaylock" # Lock screen

        # --- Window Management ---
        "$mod, F, togglefloating,"
        "$mod, P, pseudo," # Toggles pseudotiling
        "$mod, S, togglesplit," # Dwindle layout split direction

        # --- Moving Focus ---
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # --- Workspace Control ---
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        # ... add more workspaces as needed

        # --- Move Window to Workspace ---
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        # ... and so on
      ];
      
      # --- Screenshot Binding ---
      binde = [
        # Takes a screenshot of a selected region and copies it to the clipboard
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];
    };
  };
  
  # --- User Services for Desktop Components ---
  # These ensure Waybar, Dunst, and the wallpaper daemon run correctly.
  services.waybar.enable = true;
  services.dunst.enable = true;
  
  systemd.user.services.swww = {
    Unit = {
      Description = "Wallpaper Daemon";
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww init";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
