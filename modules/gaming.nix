# Add pkgs-i686 to the function arguments to receive it from the flake.
{ config, pkgs, lib, pkgs-i686, ... }:

{
  environment.systemPackages = with pkgs; [
    # ... other packages like lutris, xivlauncher, etc. ...

    # === THE NEW LAUNCHER SCRIPT ===
    # We create a new command called `steam-amd`.
    # This script explicitly sets DRI_PRIME=1 to force the use of the AMD GPU,
    # then executes the real Steam binary.
    (pkgs.writeShellScriptBin "steam-amd" ''
      #!${pkgs.bash}/bin/bash
      export DRI_PRIME=1
      exec ${pkgs.steam}/bin/steam "$@"
    '')
  ];

  environment.variables = {
    AMD_VULKAN_ICD = lib.mkForce "RADV"; # Prefer RADV for AMD GPUs
  };

  # We now use a simplified Steam configuration.
  # The override has been removed because it was not working.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    # Ensure the 32-bit drivers are available.
    extraPackages = [
      pkgs.amdvlk
      pkgs-i686.amdvlk
    ];
  };

  programs.gamemode.enable = true;
}
