{ config, pkgs, lib, ... }:

{
  # Other gaming packages can remain here
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "xivlauncher-amd-egpu" ''
      #!${pkgs.bash}/bin/bash
      export DXVK_HUD="0"
      # To ensure XIVLauncher also uses the dGPU, we add DRI_PRIME=1 here too.
      export DRI_PRIME=1
      exec "${xivlauncher}/bin/.XIVLauncher.Core-wrapped" "$@"
    '')
    lutris
    wineWowPackages.staging
    winetricks
    vulkan-tools
    radeontop
    intel-gpu-tools
    mangohud
    gamemode
    dxvk
    xivlauncher
  ];

  environment.variables = {
    # This setting is good, it forces the use of the high-performance RADV driver.
    AMD_VULKAN_ICD = lib.mkForce "RADV";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;

    # === THE FIX IS HERE ===
    # 1. Force Steam to use the AMD dGPU.
    package = pkgs.steam.override {
      extraEnv = {
        DRI_PRIME = "1";
      };
    };

    # 2. Explicitly provide 32-bit AMD drivers to Steam's environment.
    # The variable is now corrected to pkgs.pkgsi686.
    extraPackages = with pkgs; [
      amdvlk # Official AMD 64-bit Vulkan driver
      pkgs.pkgsi686.amdvlk # Official AMD 32-bit Vulkan driver
    ];
  };

  programs.gamemode.enable = true;
}
