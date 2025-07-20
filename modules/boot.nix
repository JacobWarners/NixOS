{ config, pkgs, ... }:

let
  my-plymouth-theme = pkgs.stdenv.mkDerivation {
    # We set the package name directly, removing pname and version
    name = "abstract-ring-alt-theme-1.0.0";

    # The path still points to your theme directory
    src = ../plymouth-themes/abstract-ring-alt;

    installPhase = ''
      runHook preInstall
      
      # The destination directory now has the name hard-coded
      local THEME_DIR="$out/share/plymouth/themes/abstract-ring-alt"
      mkdir -p "$THEME_DIR"
      
      # Copy all source files into the destination
      cp -R ./* "$THEME_DIR"
      
      runHook postInstall
    '';
  };
in
{
  boot = {
    plymouth = {
      enable = true;
      # The theme name is hard-coded here
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
