{ config, lib, pkgs, ... }:

{
  # Install Corectrl for GPU tweaking
  environment.systemPackages = with pkgs; [
    corectrl
    radeon-profile
  ];
  
  # Allow users to control GPU settings
  security.polkit.extraConfig = ''
  polkit.addRule(function(action, subject) {
    // Rule to allow users in "wheel" group to control CoreCtrl
    if ((action.id == "org.corectrl.helper.init" ||
         action.id == "org.corectrl.helperkiller.init") &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("wheel")) {
          return polkit.Result.YES;
    }

    // Rule to allow users in "wheel" group to manage networks
    if (action.id == "org.freedesktop.NetworkManager.network-control" &&
        subject.isInGroup("wheel")) {
          return polkit.Result.YES;
    }
  });

  '';
  
  # Enable performance governor
  powerManagement.cpuFreqGovernor = "performance";
  
  # Enable gamemode
  programs.gamemode.enable = true;
  
  # Enable better scheduler for gaming
  boot.kernelParams = [
    "transparent_hugepage=always"
    "preempt=voluntary"
  ];
}
