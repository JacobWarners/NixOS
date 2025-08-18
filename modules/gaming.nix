# Add pkgs-i686 to the function arguments to receive it from the flake.
{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    # Your XIVLauncher script
    (pkgs.writeShellScriptBin "xivlauncher-amd-egpu" ''
      #!${pkgs.bash}/bin/bash
      export DXVK_HUD="0"
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
    AMD_VULKAN_ICD = lib.mkForce "RADV"; # Prefer RADV for AMD GPUs
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;

    package = pkgs.steam.override {
      extraEnv = {
        DRI_PRIME = "1";
      };
    };

    # Use the explicitly passed 32-bit package set.
    extraPackages = [
      pkgs.amdvlk      # The 64-bit package from the default pkgs
      pkgs-i686.amdvlk # The 32-bit package from the pkgs-i686 set
    ];
  };

  programs.gamemode.enable = true;
}
