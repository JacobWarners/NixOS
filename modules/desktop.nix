{ config, pkgs, ... }:

{
  # 1. Basic X Server Setup
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
    # This ensures Hyprland is an available session for LightDM
    windowManager.hyprland.enable = true;
  };

  # 2. Configure LightDM
  services.xserver.displayManager.lightdm = {
    enable = true;
    extraConfig = ''
      logind-check-graphical=true
      '';
    };

    # 3. Customize the Slick Greeter with Auto-Login ✨
    # The greeter handles the visual login screen AND the autologin process.
    greeters.slick = {
      enable = true;
      # ✅ CORRECT LOCATION for autologin options is inside the greeter
#      autologinUser = "jake";
#      autologinSession = "hyprland"; # Tell it which session to launch

      # Your theming options remain here
#      background = ./my-background.png;
      theme = {
        package = pkgs.arc-theme;
        name = "Arc-Dark";
      };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
    };

  # 4. Ensure themes are available system-wide for LightDM
  environment.systemPackages = with pkgs; [
    arc-theme
    papirus-icon-theme
  ];

  # 5. Disable greetd to prevent conflicts
  services.greetd.enable = false;
}
