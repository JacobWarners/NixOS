{ config, pkgs, inputs, ... }:

let
  # Define a custom package for your pac.ttf font
  pacman-font = pkgs.stdenv.mkDerivation {
    pname = "pacman-custom-font";
    version = "1.0";
    src = ./dotfiles/dots/waybar/pac.ttf;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src $out/share/fonts/truetype/pac.ttf
    '';
  };

  # --- START: Bibata Cursor Theme Package ---
  # This creates a custom package for your new cursor theme.
  bibata-cursors = pkgs.stdenv.mkDerivation rec {
    pname = "bibata-cursor-theme";
    version = "2.0.6"; # The version from the GitHub repo

    # This fetches the source code directly from GitHub.
    src = pkgs.fetchFromGitHub {
      owner = "ful1e5";
      repo = "Bibata_Cursor";
      rev = "v${version}";
      hash = "sha256-iLBgQ0reg8HzUQMUcZboMYJxqpKXks5vJVZMHirK48k=";
    };

    # This script tells Nix how to install the theme.
    installPhase = ''
      mkdir -p $out/share/icons
      # We copy only the classic version you wanted.
      cp -r $src/dist/Bibata-Classic $out/share/icons/
    '';
  };
  # --- END: Bibata Cursor Theme Package ---

in {
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "25.05";

  # ... your zsh and tmux config ...
  programs.zsh = {
    enable = true;
    sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/jake/.local/share/flatpak/exports/share";
    };
  };
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      bind-key S setw synchronize-panes
    '';
  };

  home.packages = with pkgs; [
    # ... your existing packages ...
    zsh 
    yazi
    pulseaudio
    rofi-wayland
    nwg-displays
    slurp
    wl-clipboard
    grim
    libnotify
    sway-contrib.grimshot
    eww
    waybar
    nerd-fonts.jetbrains-mono
    pipewire
    wireplumber
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    pacman-font
    jq
    playerctl
    brightnessctl
    pamixer
  ];

  programs.vim = {
    # ... your vim config ...
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

  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:/run/current-system/sw/share:/usr/local/share:/usr/share";
  };

  # --- START: Set Cursor Theme ---
  # This section activates your new Bibata cursor.
  home.pointerCursor = {
    package = bibata-cursors; # Use the package from the 'let' block
    name = "Bibata-Classic";
    size = 24;
    # Ensure GTK apps use the theme
    gtk.enable = true;
  };
  # --- END: Set Cursor Theme ---

  services.ratatat-listener.enable = true;
  xdg.enable = true;
  fonts.fontconfig.enable = true;

  home.file.".zshrc".source = ./dotfiles/.zshrc;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".config/kitty".source = ./kitty;
  home.file.".config/scripts".source = ./scripts;
  xdg.configFile."eww".source = ./dotfiles/dots/eww;
  xdg.configFile."waybar".source = ./dotfiles/dots/waybar;

  wayland.windowManager.hyprland = {
    # ... your existing hyprland config ...
    enable = true;
    package = pkgs.hyprland;
    extraConfig = ''
      # ... (your extensive hyprland config is unchanged) ...
      monitor=desc:Acer Technologies XV271U M3 1322131231233, 2560x1440@179.877, 0x0, 1.00
      workspace = "2, monitor:desc:Acer Technologies XV271U M3 1322131231233";
      monitor=desc:BOE 0x095F, 2256x1504@59.999, -2256x164, 1.00
      workspace = "1, monitor:desc:BOE 0x095F";
      monitor=desc:Stargate Technology M156F01 demoset-1, 1920x1080@60.000, 2560x0, 1.00
      workspace = "3, monitor:desc:Stargate Technology M156F01 demoset-1";
      exec-once = ${pkgs.swww}/bin/swww-daemon
      exec-once = sleep 2 && swww img /home/jake/Pictures/Wallpapers/Gruvwinter.jpg
      exec-once = waybar &
      exec-once = ${pkgs.eww}/bin/eww daemon
      exec-once = sleep 2 && ${pkgs.eww}/bin/eww open dashboard
      exec-once = dunst &
      exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      general {
        gaps_in = 5
        gaps_out = 5
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        resize_on_border = false
        allow_tearing = false
        layout = dwindle
      }
      decoration {
        rounding = 10
        active_opacity = 1.0
        inactive_opacity = 1.0
        blur {
          enabled = true
          size = 3
          passes = 1
          vibrancy = 0.1696
        }
      }
      animations {
        enabled = true
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
      }
      dwindle {
        pseudotile = true
        preserve_split = true
      }
      master {
        new_status = master
      }
      misc {
        force_default_wallpaper = 0
        disable_hyprland_logo = false
        disable_splash_rendering = true;
      }
      input {
        kb_layout = us
        follow_mouse = 1
        sensitivity = 0
        touchpad {
          natural_scroll = true
          middle_button_emulation = false
        }
      }
      gestures {
        workspace_swipe = false
      }
      device {
        name = epic-mouse-v1
        sensitivity = -0.5
      }
      $mainMod = SUPER
      bind = $mainMod, Q, exec, $terminal
      bind = $mainMod, C, killactive,
      bind = $mainMod, mouse:274, killactive,
      bind = , Print, exec, grimshot --notify savecopy area
      bind = $mainMod, M, exit,
      bind = $mainMod, E, exec, $fileManager
      bind = $mainMod, V, togglefloating,
      bind = LCTRL SUPER, UP, exec, rofi -show drun
      bind = $mainMod, P, pseudo,
      bind = $mainMod, D, togglesplit,
      bind = $mainMod, left, movewindow, l
      bind = $mainMod, right, movewindow, r
      bind = $mainMod, SPACE, exec, rofi -show window
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, j, movefocus, d
      bind = $mainMod, k, movefocus, u
      bind = , F1, workspace, 1
      bind = , F2, workspace, 2
      bind = , F3, workspace, 3
      bind = , F4, workspace, 4
      bind = , F5, workspace, 5
      bind = , F6, workspace, 6
      bind = , F7, workspace, 7
      bind = , F8, workspace, 8
      bind = , F9, workspace, 9
      bind = , F10, workspace, 10
      bind = $mainMod, 1, movetoworkspace, 1
      bind = $mainMod, 2, movetoworkspace, 2
      bind = $mainMod, 3, movetoworkspace, 3
      bind = $mainMod, 4, movetoworkspace, 4
      bind = $mainMod, 5, movetoworkspace, 5
      bind = $mainMod, 6, movetoworkspace, 6
      bind = $mainMod, 7, movetoworkspace, 7
      bind = $mainMod, 8, movetoworkspace, 8
      bind = $mainMod, 9, movetoworkspace, 9
      bind = $mainMod, 10, movetoworkspace, 10
      bind = $mainMod, S, togglespecialworkspace, magic
      bind = $mainMod SHIFT, S, movetoworkspace, special:magic
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
      bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous
      windowrulev2 = noanim, class:^(ffxiv_dx11.exe)$
      windowrulev2 = opaque, class:^(ffxiv_dx11.exe)$
      windowrulev2 = fullscreen, class:^(ffxiv_dx11.exe)$
      windowrulev2 = suppressevent maximize, class:.*
      windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
    '';
  };
}
