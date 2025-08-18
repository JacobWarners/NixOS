{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    # This installs the mangohud command to your system.
    mangohud

    # This script becomes the default "steam" command.
    # It was moved inside this list to fix the syntax error.
    (pkgs.writeShellScriptBin "steam" ''
      #!${pkgs.bash}/bin/bash
      # This forces the Steam client UI to run on the stable Intel GPU.
      export DRI_PRIME=0
      # This executes the *original* steam binary.
      exec ${pkgs.steam}/bin/steam "$@"
    '')
    
    # You can add other gaming-related packages here too.
    # For example:
    # lutris
  ];

  environment.variables = {
    AMD_VULKAN_ICD = lib.mkForce "RADV";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    
    # This ensures the necessary 32-bit and 64-bit libraries
    # for drivers and MangoHud are available inside Steam's runtime.
    extraPackages = [
      pkgs.mesa
      pkgs-i686.mesa
      pkgs.mangohud
      pkgs-i686.mangohud
    ];
  };

  programs.gamemode.enable = true;
}
