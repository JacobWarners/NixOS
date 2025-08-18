{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    # ... your other packages ...

    # This script now launches Steam on the STABLE Integrated GPU.
    # We will tell Steam how to launch games on the AMD GPU separately.
    (pkgs.writeShellScriptBin "steam-stable" ''
      #!${pkgs.bash}/bin/bash
      export DRI_PRIME=0
      exec ${pkgs.steam}/bin/steam "$@"
    '')
  ];

  environment.variables = {
    AMD_VULKAN_ICD = lib.mkForce "RADV";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    extraPackages = [
      pkgs.mesa
      pkgs-i686.mesa
    ];
  };

  programs.gamemode.enable = true;
}
