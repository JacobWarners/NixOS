# modules/gaming.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # XIVLauncher script (keep your existing one if it works for FFXIV)
    (pkgs.writeShellScriptBin "xivlauncher-amd-egpu" ''
      #!${pkgs.bash}/bin/bash
      export DXVK_HUD="0"
      export DRI_PRIME=1
      # Using /run paths is fine here if it works for this specific script
      export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
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
    # Your other desired gaming packages here
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      mesa.drivers # Provides Intel Iris Xe and AMD Radeon (RADV for Vulkan, RadeonSI for OpenGL)
      # For 32-bit support for mesa.drivers, driSupport32Bit = true should handle it.
      # If you were using a specific vendor driver like amdvlk, you'd add its 32-bit counterpart here.
    ];
  };

  hardware.vulkan = {
    enable = true;
    intel.enable = true;  # For iGPU (Iris Xe)
    radeon.enable = true; # For AMD eGPU (RX 6600 using RADV)
    # amdvlk.enable = false; # Explicitly disable if you only want RADV for AMD
    driSupport32Bit = true; # Ensures 32-bit Vulkan applications can run
  };

  environment.variables = {
    AMD_VULKAN_ICD = "RADV"; # Prefer RADV for AMD GPUs
    # Consider if you need other global environment variables
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true; # Uncomment if you host dedicated servers
    # extraCompatPackages = with pkgs; [ steam-runtime ]; # Try if pressure-vessel issues persist
  };

  programs.gamemode.enable = true;

  # If you use PipeWire for audio, this can improve compatibility for some games/Proton
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   # jack.enable = true; # If you need JACK support
  # };
}
