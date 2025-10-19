{ config, pkgs, ... }:

let
  # 1. Define our recovery logic in a self-contained script.
  #    NixOS will build this script and all the paths to pkill, sleep, etc.,
  #    will be hardcoded and correct.
  recoveryScript = pkgs.writeShellScript "egpu-undock-recovery" ''
    #! ${pkgs.bash}/bin/bash
    (
      # The parentheses run this whole block in a subshell,
      # which is good practice for detaching.
      ${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland'
      ${pkgs.coreutils}/bin/sleep 1
      ${pkgs.kbd}/bin/con2fbmap 2 0
      ${pkgs.kbd}/bin/chvt 2
    ) &
  '';

in
{
  # -- eGPU Hot-Unplug Recovery (Robust Script Method) --


  # 2. Grant udev access to bash, which is needed to RUN our script.
  #    We no longer need to list the other packages here because their paths
  #    are baked directly into the script itself.
  services.udev.packages = [ pkgs.bash ];

  # 3. The udev rule is now extremely simple. It just calls our script.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", RUN+="${recoveryScript}"
  '';
}
