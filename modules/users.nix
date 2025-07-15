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

  programs.zsh.enable = true;
}

