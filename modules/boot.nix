{ config, pkgs, ... }:

let
  # Define your custom Plymouth theme as a derivation
  myCustomPlymouthTheme = pkgs.stdenv.mkDerivation {
    pname = "abstract-ring-alt"; # The name your theme will be known by in NixOS
    version = "1.0"; # You can set a version for your custom theme

    # The source of your theme files (relative to your configuration.nix).
    src = ../plymouth-themes/abstract_ring_alt; # Corrected path based on your tree structure

    # The installPhase copies the theme content into the correct Plymouth themes directory
    # within the Nix store.
    # Use ${pname} inside the string interpolation for it to be correctly evaluated.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/plymouth/themes/${pname}
      cp -r ./* $out/share/plymouth/themes/${pname}/
      runHook postInstall
    '';
  };
in
{
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      # You have "amdgpu" in initrd.kernelModules, so adding modeset here is good
      "amdgpu.modeset=1"
    ];

    plymouth = {
      enable = true;
      # Set your custom theme name here.
      # This MUST match the 'pname' defined in myCustomPlymouthTheme.
      theme = "abstract-ring-alt";
      # Add your custom theme package to the list of theme packages that Plymouth can use.
      themePackages = [ myCustomPlymouthTheme ];
    };

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "nfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    initrd = {
      # Make sure systemd is enabled in the initrd for Plymouth to function correctly
      systemd.enable = true;
      kernelModules = [ "amdgpu" ];
      luks.devices."luks-6cb1713b-252a-435f-8c5c-d4b404e9db96" = {
        device = "/dev/disk/by-uuid/6cb1713b-252a-435f-8c5c-d4b404e9db96";
      };
    };
  };
}
