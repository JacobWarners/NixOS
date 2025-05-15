{ config, pkgs, ... }:

{
  # Add custom shell script that wraps xivlauncher with your settings
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "xivlauncher-amd" ''
      export DXVK_HUD=1
      export DXVK_VSYNC=0
      export DXVK_FRAME_RATE=0
      export DRI_PRIME=1
      export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json
      exec /nix/store/knl8i4wqf8z448xc1lgqk673bs4gdsb3-XIVLauncher-1.1.2/bin/.XIVLauncher.Core-wrapped "$@"
    '')

    # Useful gaming tools and launchers
    steam
    lutris
    wine-staging
    winetricks
    vulkan-tools
    radeontop
    mangohud
    gamemode
    libva
    mesa
    libglvnd
    dxvk
    xivlauncher
  ];


  # Enable AMD Vulkan/OpenGL support system-wide
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
    amdvlk
  ];

  hardware.graphics.extraPackages32 = with pkgs.driversi686Linux; [
    amdvlk
  ];

  # Export Vulkan variables globally (can also be limited to session/scripts)
  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
  };

  # Support 32-bit audio for older games
  services.pulseaudio.support32Bit = true;

  # Enable Steam integration
  hardware.steam-hardware.enable = true;
}
