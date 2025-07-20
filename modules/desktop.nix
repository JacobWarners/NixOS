{ config, pkgs, ... }:

let
  # Define variables for your session and username for clarity.
  session = "${pkgs.hyprland}/bin/Hyprland";
  username = "jake";

  # Define the command for the qtgreet greeter.
  # It needs to be launched within 'cage' to display correctly.
  # The NixOS module for greetd automatically adds 'cage' to the path.
  qtgreet_cmd = "cage ${pkgs.greetd.qtgreet}/bin/qtgreet";

in
{
  # 1. Basic X Server/Wayland Setup
  # This is still needed for the graphical environment.
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };

  # 2. Configure greetd with qtgreet
  services.greetd = {
    enable = true;
    # When using autologin, it's best to disable restarting the service,
    # otherwise, logging out might try to autologin again immediately.
    restart = false;
    settings = {
      # This section handles auto-login.
      # It runs the specified command as your user, starting your session.
      initial_session = {
        command = session;
        user = username;
      };

      # This is the "fallback" greeter, which you will see if you log out.
      # It will run qtgreet inside the cage compositor.
      default_session = {
        command = gtkgreet_cmd;
      };
    };
  };

  # 3. Ensure qtgreet dependencies are present
  # While the module handles cage, explicitly adding qtgreet and its
  # dependencies to systemPackages is good practice.
  environment.systemPackages = with pkgs; [
    greetd.gtkgreet
    cage
    # Any other system-level packages you need...
  ];

  # 4. Disable LightDM to prevent conflicts
  services.xserver.displayManager.lightdm.enable = false;
}
