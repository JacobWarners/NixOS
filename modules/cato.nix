{ config, pkgs, lib, ... }:

let
  # Override cato-client to the latest version (Cato enforces latest)
  cato-client-latest = pkgs.cato-client.overrideAttrs (old: rec {
    version = "5.7.0.5525";
    src = pkgs.fetchurl {
      url = "https://clients.catonetworks.com/linux/${version}/cato-client-install.deb";
      sha256 = "sha256-UDIDddVk7UXiOoZGTz1757x66DmOSOGqMielSQ5W5z0=";
    };
  });
in
{
  services.cato-client = {
    enable = false;
    package = cato-client-latest;
  };

  # Cato needs /opt/cato/config to exist and be writable
  systemd.tmpfiles.rules = [
    "d /opt/cato 0755 root cato-client -"
    "d /opt/cato/config 0775 root cato-client -"
  ];

  # Add jake to the cato-client group so cato-sdp works without sudo
  users.users.jake.extraGroups = lib.mkAfter [ "cato-client" ];
}
