# modules/gaming.nix
{ config, pkgs, lib, ... }: # Added lib for potential use (e.g., lib.getName)

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "xivlauncher-amd-egpu" ''
      #!${pkgs.bash}/bin/bash
      echo "INFO: xivlauncher-amd-egpu script started."

      export DXVK_HUD="0"       # Set to "1" or "full" to enable DXVK HUD, "0" to disable.
      # export DXVK_VSYNC="0"   # "0" for off (tear_immediate), "1" for on (mailbox/fifo default for DXVK 2.x), "2" (adaptive)
      # export DXVK_FRAME_RATE="0" # "0" for uncapped, or set a specific framerate.

      # Select the eGPU (assumed to be the non-primary GPU).
      export DRI_PRIME=1
      echo "INFO: DRI_PRIME set to 1 for eGPU."

      # Explicitly set Vulkan ICDs for the AMD eGPU.
      # These /run/... paths are standard on NixOS for the Vulkan drivers, symlinked from the Nix store.
      # This helps ensure the game uses the RADV driver from your eGPU.
      export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
      echo "INFO: VK_ICD_FILENAMES set to: $VK_ICD_FILENAMES"

      # The global AMD_VULKAN_ICD="RADV" (set below) should cover this,
      # but uncomment if you need to force it specifically for this script.
      # export AMD_VULKAN_ICD="RADV"
      # echo "INFO: AMD_VULKAN_ICD (locally in script) ensured as RADV."

      echo "INFO: Executing XIVLauncher: ${xivlauncher}/bin/.XIVLauncher.Core-wrapped \"$@\""
      # The .XIVLauncher.Core-wrapped target is specific to how the xivlauncher Nix package is built.
      exec "${xivlauncher}/bin/.XIVLauncher.Core-wrapped" "$@"
    '')

    lutris
    wineWowPackages.staging # Provides both 64-bit and 32-bit Wine (staging branch). Essential for good compatibility.
    winetricks
    vulkan-tools            # For vkcube, vulkaninfo etc.
    radeontop               # AMD GPU monitoring utility.
    intel-gpu-tools       # Uncomment if you have an Intel GPU to monitor.
    mangohud
    gamemode
    dxvk                    # DXVK package (Steam often bundles its own version for Proton games).
    xivlauncher             # The FFXIV launcher package.
  ];

  hardware.opengl.enable = true;

  hardware.opengl.driSupport32Bit = true;

  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;   # Optional: Open firewall for Steam Remote Play.
  };

  # Enable GameMode for system optimizations during gameplay.
  programs.gamemode = {
    enable = true;
  };

}
