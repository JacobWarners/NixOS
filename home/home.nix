# ./home/home.nix

{ config, pkgs, ... }:

{
  # --- User and Home Manager Setup ---
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "24.05";

  # --- Combined Package List ---
  home.packages = with pkgs; [
    # Your existing packages
    zsh
    yazi

    # Hyprland Desktop Essentials
    kitty
    swaylock-effects
    rofi-wayland
    pavucontrol
    wl-clipboard
    grim
    slurp
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
    extraConfig = ''
      set -g mouse on
      bind-key S setw synchronize-panes
    '';
  };

  # ... (Your vim and librewolf configs are fine and remain unchanged) ...
  programs.vim = {
    # ... your vim config
  };
  programs.librewolf = {
    # ... your librewolf config
  };

  # --- Combined Session Variables ---
  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
    BROWSER = "librewolf";
  };

  # --- Dotfile Management ---
  home.file = {
    ".zshrc".source = ./dotfiles/.zshrc;
    ".tmux.conf".source = ./dotfiles/.tmux.conf;
    ".config/kitty".source = ./kitty;
    ".icons".source = ./dotfiles/.icons;
  };

  # --- Flatpak / XDG Support ---
  xdg.enable = true;

  # =============================================================
  # --- HYPRLAND DESKTOP ENVIRONMENT (WITH CORRECTED MODULES) ---
  # =============================================================

  # --- Enable Desktop Component Programs ---
  # This is the corrected way to enable these user services
  programs.waybar.enable = true;
  programs.dunst.enable = true;
  programs.swww.enable = true;

  # --- Hyprland Window Manager Configuration ---
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      # Startup applications
      exec-once = [
        "waybar"
        # swww is now managed by its own service, but we still need to set the image
        # This command will run after the swww daemon is started
        "swww img ~/Pictures/wallpapers/your-wallpaper.png"
      ];

      # ... (the rest of your Hyprland settings are fine) ...

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

      bind = [
        "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, D, exec, rofi -show drun"
        "$mod, L, exec, swaylock"
        "$mod, F, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, S, togglesplit,"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
      ];
      
      binde = [
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];
    };
  };
}
