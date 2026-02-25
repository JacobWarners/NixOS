# /etc/nixos/modules/fingerprint.nix
#
# This module enables fingerprint reader support for Framework 13 laptop.
# Enables fprintd for fingerprint authentication and configures PAM.

{ config, pkgs, lib, ... }:

{
  # 1. Enable the fingerprint daemon (fprintd)
  # This is the core service that manages fingerprint readers
  services.fprintd.enable = true;

  # 2. Configure PAM to allow fingerprint authentication
  # This enables fingerprint auth for sudo, login, and other PAM-protected services
  security.pam.services = {
    # Enable fingerprint for sudo commands
    sudo.fprintAuth = true;

    # Enable fingerprint for login
    login.fprintAuth = true;

    # Enable fingerprint for unlocking the screen
    # (useful for lock screens in Hyprland/other desktop environments)
    hyprlock.fprintAuth = true;
    swaylock.fprintAuth = true;

    # Enable fingerprint for polkit (for elevated privileges)
    polkit-1.fprintAuth = true;
  };

  # 3. Configure polkit to allow Bitwarden and other apps to use fingerprint
  security.polkit.extraConfig = ''
    // Allow any application to verify fingerprints
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.verify") {
        return polkit.Result.YES;
      }
    });

    // Allow enrollment (useful for initial setup)
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # 4. Add fingerprint management tools
  environment.systemPackages = with pkgs; [
    # Fingerprint management GUI (optional but useful for enrolling fingerprints)
    fprintd
  ];

  # 5. Configure systemd service to ensure fprintd starts properly
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
  };
}
