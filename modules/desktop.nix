{ config, pkgs, ... }:

let
  # Define variables for clarity.
  session = "${pkgs.hyprland}/bin/Hyprland";
  username = "jake";
in
{
  # 1. Basic X Server/Wayland Setup
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  # 2. Configure greetd with gtkgreet
  services.greetd = {
    enable = true;
    restart = false; # Good for auto-login setups
    settings = {
      # This handles your auto-login
      initial_session = {
        command = session;
        user = username;
      };

      # This is the greeter you see when you log out
      default_session = {
        # The command is much simpler for gtkgreet
        command = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
      };
    };
  };

  # 3. Theme gtkgreet ✨
  # This is where you customize the look of the login screen.
  programs.gtkgreet = {
    enable = true;
    # Tell gtkgreet to use Wayland
    wayland.enable = true;
    style = {
      # Set your background image here.
      # The path is relative to the root of your config folder.
      background = ./modules/ai-landscape.png;

      # You can add any custom GTK CSS here!
      # This example makes the login box semi-transparent.
      css = ''
        window {
            background-color: rgba(0, 0, 0, 0.5);
        }
      '';
    };
  };

  # 4. Ensure gtkgreet is in the system environment
  environment.systemPackages = with pkgs; [
    greetd.gtkgreet # Swapped from qtgreet
  ];

  # 5. Make sure other display managers are disabled
  services.xserver.displayManager.lightdm.enable = false;
}
