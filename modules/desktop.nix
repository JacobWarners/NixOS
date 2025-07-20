{ config, pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland";
  username = "jake";
in
{
  # Enable the X server if needed
  services.xserver = {
#    displayManager.gdm.enable = true;
#    desktopManager.gnome.enable = true;
    #  displayManager.startx.enable = true;
    #  displayManager.gdm.wayland = false;
    enable = true;
    videoDrivers = ["amdgpu"];
  };



  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${session}";
        user = "${username}";
      };
      default_session = {
        command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${session}";
        user = "greeter";
      };
    };
  };
}
