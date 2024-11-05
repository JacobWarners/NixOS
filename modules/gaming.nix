{ config, pkgs, ... }:

{
  # Enable Steam
  hardware.graphics.enable32Bit= true;
  hardware.pulseaudio.support32Bit = true;

  # Install FFXIV launcher (assuming it's available in Nixpkgs)
  environment.systemPackages = with pkgs; [
    steam
    mesa
    vulkan-loader
    libglvnd
    libva
    xivlauncher     # Replace with the actual package name if different
    lutris
  ];

  # Enable 32-bit support for gaming
#  hardware.opengl = {
 #   enable = true;
  #  driSupport32Bit = true;
#    extraPackages32 = with pkgs.pkgsi686Linux; [
 #     vaapiIntel
  #    vaapiVdpau
   #   libvdpau-va-gl
#    ];
#    services.xserver.videoDrivers = ["nvidia"];
 # };
}

