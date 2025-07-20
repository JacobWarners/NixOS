{ config, pkgs, ... }:

let
  myCustomPlymouthTheme = pkgs.runCommand "abstract-ring-alt-plymouth-theme" { } ''
    # --- STARTING DEBUG ---
    echo "Nix build environment debug started."
    echo "Step 1: Listing the source directory that Nix provides:"
    ls -laR ${../plymouth-themes/abstract_ring_alt}
    
    # --- RUNNING COPY ---
    local THEME_DIR="$out/share/plymouth/themes/abstract-ring-alt"
    mkdir -p "$THEME_DIR"
    cp -R ${../plymouth-themes/abstract_ring_alt}/. "$THEME_DIR"
    
    # --- VERIFYING COPY ---
    echo "Step 2: Listing the destination directory after copy:"
    ls -laR "$THEME_DIR"
    echo "Nix build environment debug finished."
    # --- ENDING DEBUG ---
  '';
in
{
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
