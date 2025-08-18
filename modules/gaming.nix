{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "steam" ''
      #!${pkgs.bash}/bin/bash
      export DRI_PRIME=0
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
    
    # === FINAL MANGO HUD FIX ===
    # Add both 64-bit and 32-bit MangoHud to ensure it works
    # with any game, regardless of its architecture.
    extraPackages = [
      pkgs.mesa
      pkgs-i686.mesa
      pkgs.mangohud
      pkgs-i686.mangohud
    ];
  };

  programs.gamemode.enable = true;
}
