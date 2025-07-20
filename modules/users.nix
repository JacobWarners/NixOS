{ config, pkgs, ... }:

{
  users.users.jake = {
    isNormalUser = true;
    home = "/home/jake";
    shell = pkgs.zsh;
    initialHashedPassword = "$y$j9T$MkzXr4RqnBYu92A6DSwJv1$Hxj3vUPY3vCvPyJ1Z8vfaQhSEn4ZO0vKNsJYhpnJkF.";
    extraGroups = [ "wheel" "docker" "podman" "dialout" "libinput" "input"];
    icon = ./ai-landscape.png
  };

  # Optionally, disable root login via SSH for security
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
# In /etc/nixos/configuration.nix
security.sudo.extraConfig = ''
  # Give user 'jake' passwordless sudo access to all commands.
  # WARNING: For testing purposes only.
  jake ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/cpupower
'';
#security.sudo.extraRules = [
#  {
#    users = [ "jake" ];
#    # We are defining two passwordless commands for user "jake".
#    commands = [
#      {
#        # Rule 1: Authorize the script itself.
#        command = "/home/jake/.config/waybar/scripts/governor.sh";
#        options = [ "NOPASSWD" ];
#      }
##      {
#        # Rule 2: Authorize the cpupower command directly.
#        command = "/run/current-system/sw/bin/cpupower";
#        options = [ "NOPASSWD" ];
#      }
#    ];
#  }
#];

  programs.zsh.enable = true;
}

