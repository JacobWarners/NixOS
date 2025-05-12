{ config, pkgs, ... }:

{
  # Enable OpenGL and AMD-specific packages
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ amdvlk ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  # Install LACT and configure its systemd service
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd = {
    wantedBy = [ "multi-user.target" ];
    description = "Linux AMDGPU Controller Daemon";
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "always";
    };
  };
}
