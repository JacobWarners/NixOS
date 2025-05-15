{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "xivlauncher-amd" ''
      export DXVK_HUD=1
      export DXVK_VSYNC=0
      export DXVK_FRAME_RATE=0
      export DRI_PRIME=1
      export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json
      exec /nix/store/knl8i4wqf8z448xc1lgqk673bs4gdsb3-XIVLauncher-1.1.2/bin/.XIVLauncher.Core-wrapped "$@"
    '')

    steam
    mesa
    vulkan-loader
    libglvnd
    libva
    xivlauncher
    lutris
    wine
    winetricks
  ];

  # Enable Steam-related support
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.pulseaudio.support32Bit = true;
}
