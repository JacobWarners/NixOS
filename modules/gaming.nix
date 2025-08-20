{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    # General gaming packages
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
    moonlight-qt

    # Custom script to run XIVLauncher on the AMD eGPU
    (pkgs.writeShellScriptBin "xivlauncher-amd-egpu" ''
      #!${pkgs.bash}/bin/bash
      export DXVK_HUD="0"
      export DRI_PRIME=1
      exec "${xivlauncher}/bin/.XIVLauncher.Core-wrapped" "$@"
    '')

    # Custom script to force the Steam UI to use the Intel iGPU
    (pkgs.writeShellScriptBin "steam" ''
      #!${pkgs.bash}/bin/bash
      export DRI_PRIME=0
      exec ${pkgs.steam}/bin/steam "$@"
    '')
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa # Provides OpenGL and Vulkan drivers for Intel and AMD (RADV)
    ];
  };

  # Set the preferred Vulkan ICD for AMD GPUs to RADV
  # `lib.mkForce` is used to ensure this setting takes precedence
  environment.variables = {
    AMD_VULKAN_ICD = lib.mkForce "RADV";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;

    # Ensure necessary 32-bit and 64-bit libraries for drivers and MangoHud
    # are available within Steam's runtime environment for game compatibility.
    extraPackages = [
      pkgs.mesa
      pkgs-i686.mesa
      pkgs.mangohud
      pkgs-i686.mangohud
    ];
  };

  programs.gamemode.enable = true;
}
