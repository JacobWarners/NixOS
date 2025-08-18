{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    # ... your other packages ...
    
    # === ADD THIS LINE ===
    # This installs the mangohud command to your system, making it available.
    mangohud
  ];

  # This script now launches Steam on the STABLE Integrated GPU.
  # We will tell Steam how to launch games on the AMD GPU separately.
  (pkgs.writeShellScriptBin "steam" ''
    #!${pkgs.bash}/bin/bash
    export DRI_PRIME=0
    exec ${pkgs.steam}/bin/steam "$@"
  '');

  environment.variables = {
    AMD_VULKAN_ICD = lib.mkForce "RADV";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    
    # This ensures the necessary libraries are available inside Steam's runtime
    extraPackages = [
      pkgs.mesa
      pkgs-i686.mesa
      pkgs.mangohud
      pkgs-i686.mangohud
    ];
  };

  programs.gamemode.enable = true;
}
