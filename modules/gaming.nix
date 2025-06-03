# modules/gaming.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Your XIVLauncher script
    (pkgs.writeShellScriptBin "xivlauncher-amd-egpu" ''
      #!${pkgs.bash}/bin/bash
      export DXVK_HUD="0"
      export DRI_PRIME=1
      export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
      exec "${xivlauncher}/bin/.XIVLauncher.Core-wrapped" "$@"
    '')

    lutris
    wineWowPackages.staging
    winetricks
    vulkan-tools # This provides vulkaninfo and ensures vulkan-loader is present
    radeontop
    intel-gpu-tools
    mangohud
    gamemode
    dxvk
    xivlauncher
    # Your other desired gaming packages here
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      mesa.drivers # This package provides both OpenGL and Vulkan drivers (Intel and AMD RADV)
    ];
  };

  # We are intentionally omitting the explicit hardware.vulkan section for now.
  # The mesa.drivers package and vulkan-tools should be sufficient to set up
  # Vulkan ICDs for Intel and AMD. We will verify this with vulkaninfo.

  environment.variables = {
    AMD_VULKAN_ICD = "RADV"; # Prefer RADV for AMD GPUs
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
    # extraCompatPackages = with pkgs; [ steam-runtime ];
  };

  programs.gamemode.enable = true;

  # Optional: If you use PipeWire
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };
}
