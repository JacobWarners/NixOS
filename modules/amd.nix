{ config, pkgs, ... }:

let
  # Custom amdgpu kernel module derivation
  amdgpu-kernel-module = pkgs.callPackage ./packages/amdgpu-kernel-module.nix {
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
    driSupport = true;
    driSupport32Bit = true; # For 32-bit applications
    extraPackages = with pkgs; [ amdvlk ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  # Install and enable LACT (AMD GPU control daemon)
  environment.systemPackages = with pkgs; [ lact ];
  services.lact.enable = true; # Simplifies lactd service configuration

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
}
