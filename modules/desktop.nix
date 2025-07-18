{ config, pkgs, ... }:
{
  # Enable the X server if needed
  services.xserver = {
#    displayManager.gdm.enable = true;
#    desktopManager.gnome.enable = true;
    #  displayManager.startx.enable = true;
    #  displayManager.gdm.wayland = false;
    enable = true;
    videoDrivers = ["modesetting" "amdgpu"];
  };

  hardware.graphics = {
    enable = true;
    driSupport32Bit = true;
    # Ensure Mesa packages for both GPUs are available
    extraPackages = with pkgs; [
      intel-media-driver # VAAPI driver for Intel
      libva-utils        # VAAPI tools
    ];
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
