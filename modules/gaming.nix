# modules/gaming.nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "xivlauncher-amd-egpu" ''
      # This script is specifically for running XIVLauncher on the eGPU
      export DXVK_HUD=1
      export DXVK_VSYNC=0
      export DXVK_FRAME_RATE=0
      export DRI_PRIME=1 # Selects the eGPU
      # Forcing RADV here is fine as we only call this when targeting the AMD eGPU
      export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json
      exec ${xivlauncher}/bin/.XIVLauncher.Core-wrapped "$@"
    '')

    steam
    lutris
    wine-staging # or wineWowPackages.stable
    winetricks
    vulkan-tools # very useful for debugging
    radeontop # for monitoring AMD GPU
    # intel-gpu-tools # for monitoring Intel GPU (optional)
    mangohud
    gamemode
    dxvk
    xivlauncher
  ];

  hardware.opengl.driSupport32Bit = true;

  # Global environment variables
  environment.variables = {
    AMD_VULKAN_ICD = "RADV"; # If an AMD GPU is used, prefer RADV. No effect on Intel.
  };

  # Enable Steam integration (good, handles udev rules, 32-bit libs, etc.)
  programs.steam.enable = true;

}
