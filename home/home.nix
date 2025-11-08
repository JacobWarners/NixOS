{ config, pkgs, inputs, ... }:

let
  # --- Font Derivation ---
  sonic-font = pkgs.stdenv.mkDerivation {
    pname = "sonic-custom-font";
    version = "1.0";
    src = ./fonts/Sonic-Regular.otf;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/fonts/opentype
      cp $src $out/share/fonts/opentype/Sonic-Regular.otf
    '';
  };

  # --- Rofi Palette Selection ---
  active-rofi-palette = "catppuccin";
  palette-map = {
    gruvbox = ./rofi-themes/gruvbox.rasi;
    catppuccin = ./rofi-themes/catppuccin.rasi;
  };
  selected-palette-text = builtins.readFile palette-map.${active-rofi-palette};

  # --- Packaged Script for Toggling F-Keys ---
  toggleFkeysScript = pkgs.writeShellScriptBin "toggle-fkeys" ''
    #!${pkgs.runtimeShell}
    LOCK_FILE="/tmp/hypr_fkeys_disabled.lock"
    if [ -f "$LOCK_FILE" ]; then
        ${pkgs.libnotify}/bin/notify-send "Hyprland" "F-Keys ENABLED for workspaces" -u normal
        ${pkgs.hyprland}/bin/hyprctl keyword source ~/.config/hypr/fkeys.conf
        rm "$LOCK_FILE"
    else
        ${pkgs.libnotify}/bin/notify-send "Hyprland" "F-Keys DISABLED for gaming" -u normal
        for i in $(${pkgs.coreutils}/bin/seq 1 10); do
            ${pkgs.hyprland}/bin/hyprctl keyword unbind ",F$i"
        done
        touch "$LOCK_FILE"
    fi
  '';

  # --- THE FINAL, WORKING SCRIPT ---
  # We now call 'pactl' directly, relying on the PATH, which solves the
  # "No such file or directory" error.
  createVirtualSinkScript = pkgs.writeShellScriptBin "create-virtual-sink" ''
    #!${pkgs.runtimeShell}
    
    # Wait until the pactl command can successfully connect to the server.
    until pactl info >/dev/null 2>&1; do
      sleep 1
    done

    # Now that the server is ready, load the modules.
    pactl load-module module-null-sink sink_name=error_sounds sink_properties=device.description=ErrorSounds
    pactl load-module module-loopback source=error_sounds.monitor
  '';

in
{
  home.username = "jake";
  home.stateVersion = "25.05";

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      bind-key S setw synchronize-panes
    '';
  };

  qt.enable = true;
  qt.platformTheme.name = "gtk";

  gtk = {
    enable = true;
    cursorTheme = { name = "Bibata-Modern-Classic"; package = pkgs.bibata-cursors; size = 24; };
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders.override { flavor = "macchiato"; accent = "teal"; };
      name = "Papirus-Dark";
    };
    theme = {
      name = "catppuccin-macchiato-mauve-compact";
      package = pkgs.catppuccin-gtk.override { accents = ["mauve"]; variant = "macchiato"; size = "compact"; };
    };
    gtk3.extraConfig = { Settings = '' gtk-application-prefer-dark-theme=1 ''; };
    gtk4.extraConfig = { Settings = '' gtk-application-prefer-dark-theme=1 ''; };
  };

  home.packages = with pkgs; [
    zsh yazi polkit_gnome pulseaudio direnv nix-direnv nwg-displays imagemagick slurp wlogout
    swaylock-effects wl-clipboard cliphist wallust xclip grim libnotify sway-contrib.grimshot
    eww waybar nerd-fonts.jetbrains-mono pipewire wireplumber sonic-font jq playerctl
    brightnessctl pamixer

    # Add our custom script packages to the user's environment
    toggleFkeysScript
    createVirtualSinkScript
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim nvim-lspconfig mason-nvim mason-lspconfig-nvim nvim-cmp
      cmp-nvim-lsp cmp-buffer luasnip gruvbox vim-sensible
    ];
  };

  xdg.configFile."nvim".source = ./nvim;

  home.file = {
    ".config/rofi/launcher.rasi".source = ./rofi-themes/launcher_style_6.rasi;
    ".config/rofi/shared/fonts.rasi".source = ./rofi-themes/fonts.rasi;
    ".config/rofi/shared/colors.rasi".text = selected-palette-text;
    ".zshrc".source = ./dotfiles/.zshrc;
    ".tmux.conf".source = ./dotfiles/.tmux.conf;
    ".config/kitty".source = ./kitty;
    ".config/wallust".source = ./wallust;
    ".config/scripts" = {
      source = ./scripts;
      recursive = true;
      executable = true;
    };
    ".config/scripts/undock-helper.sh" = {
      source = ./scripts/undock-helper.sh;
      executable = true;
    };
  };

  programs.rofi = {
    enable = true;
    theme = "${config.home.homeDirectory}/.config/rofi/launcher.rasi";
    package = pkgs.rofi-wayland;
  };

  services.ratatat-listener.enable = true;
  fonts.fontconfig.enable = true;

  xdg.configFile = {
    "eww".source = ./dotfiles/dots/eww;
    "wlogout".source = ./wlogout;
    "waybar".source = ./dotfiles/dots/waybar;
    "hypr/fkeys.conf" = {
      text = ''
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
      '';
    };
  };

  xdg.configFile = {
    # 1. Create a brand new .desktop file for our custom entry.
    # The path is relative to ~/.config, so we use ../ to get to ~/.local/share
    "../local/share/applications/librewolf-fire.desktop" = {
      # Use `text` to specify the exact content of the file.
      text = ''
        [Desktop Entry]
        Name=LibreWolf
        Comment=Browse the web
        GenericName=Web Browser
        Exec=librewolf %U
        Icon=librewolf
        Type=Application
        Terminal=false
        Categories=Network;WebBrowser;
        Keywords=fire;browser;internet;
      '';
    };

    # 2. Create a file to hide the original system-wide entry.
    # By creating a file with the same name in the user's local directory,
    # it overrides the system one.
    "../local/share/applications/librewolf.desktop" = {
      text = ''
        [Desktop Entry]
        NoDisplay=true
      '';
    };
  };

  dconf.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    extraConfig = ''
      # Your full, working, multi-line Hyprland config
      monitor=desc:Acer Technologies XV271U M3 1322131231233, 2560x1440@179.877, 0x0, 1.00
      workspace = "2, monitor:desc:Acer Technologies XV271U M3 1322131231233";
      monitor=desc:BOE 0x095F, 2256x1504@59.999, -2256x164, 1.00
      workspace = "1, monitor:desc:BOE 0x095F";
      monitor=desc:Stargate Technology M156F01 demoset-1, 1920x1080@60.000, 2560x0, 1.00
      workspace = "3, monitor:desc:Stargate Technology M156F01 demoset-1";
      
      $terminal = kitty
      $fileManager = nautilus
      $menu = rofi-wayland --show drun
      
      # --- STARTUP APPLICATIONS ---
      exec-once = ${pkgs.swww}/bin/swww-daemon
      exec-once = sleep 2 && swww img ${config.home.homeDirectory}/Pictures/Wallpapers/Gruvwinter.jpg
      exec-once = waybar &
      exec-once = ${pkgs.eww}/bin/eww daemon
      exec-once = sleep 2 && ${pkgs.eww}/bin/eww open dashboard
      exec-once = dunst &
      exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store
      exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
      
      # --- FINAL WORKING VIRTUAL SINK COMMAND ---
      exec-once = create-virtual-sink &
      
      # --- ENVIRONMENT VARIABLES ---
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      
      # --- SETTINGS ---
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
          clickfinger_behavior = 1
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
      
      # --- KEYBINDINGS ---
      $mainMod = SUPER
      bind = $mainMod, Q, exec, $terminal
      bind = $mainMod, C, killactive,
      bind = $mainMod, mouse:274, killactive,
      bind = , Print, exec, grimshot --notify savecopy area
      bind = $mainMod, M, exit,
      bind = $mainMod, T, exec, ${config.home.homeDirectory}/.config/scripts/rofi-theme-selector.sh
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
      bind = SUPER, U, exec, ${config.home.homeDirectory}/.config/scripts/undock.sh
      source = ~/.config/hypr/fkeys.conf
      bind = SUPER, F12, exec, toggle-fkeys
      bind = $mainMod, 1, movetoworkspace, 1
      bind = $mainMod, 2, movetoworkspace, 2
      bind = $mainMod, 3, movetoworkspace, 3
      bind = $mainMod, 4, movetoworkspace, 4
      bind = $mainMod, 5, movetoworkspace, 5
      bind = $mainMod, 6, movetoworkspace, 6
      bind = $mainMod, 7, movetoworkspace, 7
      bind = $mainMod, 8, movetoworkspace, 8
      bind = $mainMod, 9, movetoworkspace, 9
      bind = $mainMod, 0, movetoworkspace, 10
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
      
      # --- WINDOW RULES ---
      windowrulev2 = noanim, class:^(ffxiv_dx11.exe)$
      windowrulev2 = opaque, class:^(ffxiv_dx11.exe)$
      windowrulev2 = fullscreen, class:^(ffxiv_dx11.exe)$
      windowrulev2 = movetomonitor, DP-3, class:^(ffxiv_dx11.exe)$
      windowrulev2 = center, 1, class:^(ffxiv_dx11.exe)$
      windowrulev2 = suppressevent maximize, class:.*
      windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
      windowrulev2 = float, class:^(zoom)$, title:^(Sign In with SSO)$
      windowrulev2 = float, class:^(zoom)$, x11_window_type:^(dialog)$
    '';
  };
}
