{lib, config, pkgs, ... }: 
{
  # Enable the X server if needed
  services.xserver.enable = true;

  # Configure GDM and GNOME
  services.displayManager.sddm.enable = true;
#  services.displayManager.sddm.wayland.enable = true;
#  services.xserver.desktopManager.gnome.enable = true;



  # Enable KDE Plasma desktop
  services.xserver.desktopManager.plasma5.enable = true;

  # Prioritize KDE's ksshaskpass
  programs.ssh.askPassword = lib.mkForce "/nix/store/d5q0fac1zwx4kj9djm49d4l2avgkj6mq-ksshaskpass-5.27.11/bin/ksshaskpass";


#################################  # Hyprland stuff###########################################
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
};

  environment.sessionVariables = {
#    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
};

  hardware = {
    graphics.enable = true;
    nvidia.modesetting.enable = true;
};

  environment.systemPackages = [
  #Bar at top
   (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    })
  )

# 3 packs that allow screen capping
    pkgs.xwaylandvideobridge
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard-rs
#Notifications daemon
    pkgs.dunst
#they all sorta use this
    pkgs.libnotify
#Networkmanager waybar
    pkgs.networkmanagerapplet
#Sound
    pkgs.wireplumber
    pkgs.pavucontrol
#Dont' remember
    pkgs.eww
#Wallpaper
    pkgs.swww
#app launcher
    pkgs.rofi-wayland
#icons
    pkgs.font-awesome
#Brightness
    pkgs.light

];
  xdg.portal.enable = true;
#  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk];


  # Create a session file for Hyprland
 # environment.etc."xdg/wayland-sessions/hyprland.desktop".text = ''
 #   [Desktop Entry]
 #   Name=Hyprland
 #   Comment=Hyprland Wayland Compositor
 #   Exec=${pkgs.hyprland}/bin/hyprland
 #   Type=Application
 # '';

  # Add Hyprland to the display manager sessions
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];
  fonts.packages = with pkgs; [
  pkgs.nerdfonts
  pkgs.font-awesome
];

}

