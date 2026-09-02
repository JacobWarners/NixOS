{ config, pkgs, ... }:

let
  # Define your session and user for the auto-login
  # start-hyprland is the supported entrypoint (it is what the packaged
  # hyprland.desktop session file execs). It wraps the compositor in a watchdog
  # that restarts it after an unclean exit -- relevant here because eGPU
  # teardown/redock wedges can kill Hyprland -- and runs the Nix/nixGL
  # environment check. Launching bin/Hyprland directly is the raw compositor:
  # no watchdog, and it prints the "started without start-hyprland" banner on
  # every boot.
  session = "${pkgs.hyprland}/bin/start-hyprland";
  username = "jake";

in
{
  # 1. Basic graphical environment setup
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];


  };
  services.desktopManager.plasma6.enable = true;
  # 2. Minimal greetd + tuigreet configuration
  services.greetd = {
    enable = true;
    # Use the text-based tuigreet
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${session}";
    # This section handles the auto-login on boot
    settings.initial_session = {
      command = session;
      user = username;
    };
  };

  # 3. Ensure tuigreet is installed
  environment.systemPackages = [ pkgs.tuigreet ];
  security.polkit.enable = true;
  console.enable= true;

}
