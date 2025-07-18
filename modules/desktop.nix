{ config, pkgs, ... }:
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
    default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";
      user = "greeter";
    };

  };
};
}
