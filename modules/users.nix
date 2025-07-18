{ config, pkgs, ... }:

{
  users.users.jake = {
    isNormalUser = true;
    home = "/home/jake";
    shell = pkgs.zsh;
    initialHashedPassword = "$y$j9T$MkzXr4RqnBYu92A6DSwJv1$Hxj3vUPY3vCvPyJ1Z8vfaQhSEn4ZO0vKNsJYhpnJkF.";
    extraGroups = [ "wheel" "docker" "podman" "dialout" ];
  };

  # Optionally, disable root login via SSH for security
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
# In /etc/nixos/configuration.nix
security.sudo.extraRules = [
  {
    users = [ "jake" ];
    commands = [
      {
        # Authorize the cpupower command itself using its canonical NixOS path
        command = "/run/current-system/sw/bin/cpupower";
        options = [ "NOPASSWD" ];
      }
    ];
  }
];

  # Sudo configuration for passwordless cpupower
 
   security.sudo.extraRules = [
   {
     users = [ "jake" ];
     commands = [
       {
         # Authorize the script itself to be run with passwordless sudo
         command = "/home/jake/.config/waybar/scripts/cycle_governor.sh";
         options = [ "NOPASSWD" ];
       }
     ];
   }
 ];
  programs.zsh.enable = true;
}

