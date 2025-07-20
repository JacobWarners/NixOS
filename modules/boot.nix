{ config, pkgs, ... }:

let
  # This builder successfully bypasses the 'pname' error in your environment.
  myCustomPlymouthTheme = pkgs.runCommand "abstract-ring-alt-plymouth-theme" { } ''
    # Define the destination directory and hard-code the theme name
    local THEME_DIR="$out/share/plymouth/themes/abstract-ring-alt"
    mkdir -p "$THEME_DIR"

    # Use the robust copy method to copy all source files
    cp -R ${../plymouth-themes/abstract_ring_alt}/. "$THEME_DIR"
  '';
in
{
  # All boot options are correctly nested inside this single 'boot' block.
  boot = {
    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [ myCustomPlymouthTheme ];
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
