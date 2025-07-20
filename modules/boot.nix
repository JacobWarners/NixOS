{ config, pkgs, ... }:

let
  my-plymouth-theme = pkgs.stdenv.mkDerivation {
    pname = "abstract-ring-alt";
    version = "1.0.0";

    # The standard way to define the source.
    # The builder will automatically go into this directory.
    src = ../plymouth-themes/abstract_ring_alt;

    # This is the standard install phase.
    installPhase = ''
      runHook preInstall

      # The destination directory uses the pname variable
      local THEME_DIR="$out/share/plymouth/themes/${pname}"
      mkdir -p "$THEME_DIR"

      # Copy all files from the source directory into the destination
      cp -R ./* "$THEME_DIR"

      runHook postInstall
    '';
  };
in
{
  # All boot options are correctly nested inside this block
  boot = {
    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [ my-plymouth-theme ];
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "amdgpu.modeset=1"
    ];

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "nfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    initrd = {
      systemd.enable = true;
      kernelModules = [ "amdgpu" ];
      luks.devices."luks-6cb1713b-252a-435f-8c5c-d4b404e9db96" = {
        device = "/dev/disk/by-uuid/6cb1713b-252a-435f-8c5c-d4b404e9db96";
      };
    };
  };
}
