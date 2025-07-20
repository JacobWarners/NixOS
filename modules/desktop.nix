{ config, pkgs, ... }:

{
  # 1. Basic X Server Setup
  # This remains the same to enable the graphical environment.
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };

  # 2. Configure LightDM with Auto-Login 🚀
  services.xserver.displayManager.lightdm = {
    enable = true;
    # Auto-login the specified user.
#    autologinUser = "jake";
    # Set a timeout for auto-login, or set to 0 to log in immediately.
    autoLogin.timeout = 0;
  };

  # 3. Customize the Slick Greeter ✨
  # This provides the themed appearance you see when logging out.
  services.xserver.displayManager.lightdm.greeters.slick = {
    enable = true;
    # Set the background image. The './' syntax references a file
    # in the same directory as this configuration file.
    background = ./ai-landscape.png;

    # Set the theme for the greeter's window.
    # Since your themes are in home-manager, we must also add the theme package
    # to systemPackages so LightDM can find it.
    theme = {
      package = pkgs.arc-theme; # Example theme: Arc
      name = "Arc-Dark";
    };

    # Set the icon theme.
    iconTheme = {
      package = pkgs.papirus-icon-theme; # Example theme: Papirus
      name = "Papirus-Dark";
    };
  };

  # 4. Ensure themes are available to LightDM
  # Even though your themes are in home.nix for your user, the LightDM greeter
  # runs as its own user and needs system-level access to the theme packages.
  environment.systemPackages = with pkgs; [
    arc-theme
    papirus-icon-theme
  ];

  # 5. Disable greetd
  # This ensures your old display manager does not conflict with the new one.
  services.greetd.enable = false;
}
