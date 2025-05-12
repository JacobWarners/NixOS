{ config, pkgs, ... }:

let
  # Custom amdgpu kernel module derivation
  amdgpu-kernel-module = pkgs.callPackage ./modules/amd.nix {
    kernel = config.boot.kernelPackages.kernel;
  };

  # AMDGPU stability patch for kernel (example for linux 6.13)
  amdgpu-stability-patch = pkgs.fetchpatch {
    name = "amdgpu-stability-patch";
    url = "https://github.com/torvalds/linux/compare/ffd294d346d185b70e28b1a28abe367bbfe53c04...SeryogaBrigada:linux:4c55a12d64d769f925ef049dd6a92166f7841453.diff";
    hash = "sha256-q/gWUPmKHFBHp7V15BW4ixfUn1kaeJhgDs0okeOGG9c=";
  };
in
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

  # Apply AMDGPU stability patch to kernel module
  boot.extraModulePackages = [
    (amdgpu-kernel-module.overrideAttrs (_: {
      patches = [ amdgpu-stability-patch ];
    }))
  ];

  # Ensure amdgpu is loaded early
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Optional: Include AMD firmware
  hardware.firmware = [ pkgs.linux-firmware ];

  # Xorg driver for AMD
  services.xserver.videoDrivers = [ "amdgpu" ];
}
