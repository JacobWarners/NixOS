{ config, pkgs, ... }:

let
  # Define your session and user for the auto-login
  session = "${pkgs.hyprland}/bin/Hyprland";
  username = "jake";

in
{
  # 1. Basic graphical environment setup
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };

  # 2. Minimal greetd + tuigreet configuration
  services.greetd = {
    enable = true;
    # Use the text-based tuigreet
    settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${session}";

    # This section handles the auto-login on boot
    settings.initial_session = {
      command = session;
      user = username;
    };
  };

  # 3. Ensure tuigreet is installed
  environment.systemPackages = [ pkgs.greetd.tuigreet ];

  # 4. Explicitly disable everything else to be safe
  programs.gtkgreet.enable = false;
  services.accounts-daemon.enable = false;
  services.xserver.displayManager.lightdm.enable = false;
}
