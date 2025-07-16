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
      if ((action.id == "org.corectrl.helper.init" ||
           action.id == "org.corectrl.helperkiller.init") &&
          subject.local == true &&
          subject.active == true &&
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
