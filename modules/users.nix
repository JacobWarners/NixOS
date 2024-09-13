{ config, pkgs, ... }:

{
  users.users.jake = {
    isNormalUser = true;
    home = "/home/jake";
    shell = pkgs.zsh;
    initialHashedPassword = "$6$zOqRN8BA7b4p60.s$Wl9h2sQFUmjP/AJ8PSZ2daa2qecUVDH16NXeJa2BLxH8GFwqSaYVJxta6ZWM7augBdQyX5jb0UXt7wAW0aioG.
";
    extraGroups = [ "wheel" "docker" "podman" ];
    openssh.authorizedKeys.keys = [
      # Add your public SSH keys here if needed
    ];
  };

  # Optionally, disable root login via SSH for security
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
  };
}

