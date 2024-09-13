{ config, pkgs, ... }:

{
  # Enable Steam
  services.steam.enable = true;

  # Install FFXIV launcher (assuming it's available in Nixpkgs)
  environment.systemPackages = with pkgs; [
    ffxiv-launcher     # Replace with the actual package name if different
  ];

  # Enable 32-bit support for gaming
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}

