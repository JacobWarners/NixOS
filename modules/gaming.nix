{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "steam-amd" ''
      #!${pkgs.bash}/bin/bash
      export DRI_PRIME=1
      exec ${pkgs.steam}/bin/steam "$@"
    '')
    # ... your other packages
  ];

  environment.variables = {
    AMD_VULKAN_ICD = lib.mkForce "RADV";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;

    # === FINAL DRIVER FIX ===
    # We are now providing the full Mesa package for both 64-bit and 32-bit.
    # This contains the RADV Vulkan driver Steam is trying to use, ensuring
    # perfect compatibility within its runtime environment.
    extraPackages = [
      pkgs.mesa
      pkgs-i686.mesa
    ];
  };

  programs.gamemode.enable = true;
}
