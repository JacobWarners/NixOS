# ./home/home.nix

{ config, pkgs, ... }:

{
  # --- User and Home Manager Setup ---
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "24.05";

  # --- Combined Package List ---
  home.packages = with pkgs; [
    zsh
    yazi
    kitty
    swaylock-effects
    rofi-wayland
    pavucontrol
    wl-clipboard
    grim
    slurp
    swww # Keep the package here
  ];
  
  # ... (Your zsh, tmux, vim, librewolf, session variables, and dotfiles sections are all correct and do not need to be changed) ...
  programs.zsh = {
     # ...
  };
  programs.tmux = {
     # ...
  };
  programs.vim = {
    # ...
  };
  programs.librewolf = {
    # ...
  };
  home.sessionVariables = {
    # ...
  };
  home.file = {
    # ...
  };
  xdg.enable = true;


  # =============================================================
  # --- HYPRLAND DESKTOP ENVIRONMENT (CORRECTED AGAIN) ---
  # =============================================================

  # --- Enable Desktop Programs & Services ---
  programs.waybar.enable = true;   # This is a program, so this is CORRECT.
  services.dunst.enable = true;    # Dunst is a service, so this is the CORRECT option.

  # --- Hyprland Window Manager Configuration ---
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      exec-once = [
        "waybar"
        # The swww daemon will be started by its systemd service below.
        # This command just sets the image after the daemon is ready.
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

  # --- Systemd User Service for swww ---
  # For programs without a dedicated HM module, this is the robust way to create a service.
  systemd.user.services.swww = {
    Unit = {
      Description = "Wallpaper Daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
