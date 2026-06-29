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
    enable = true;
    package = cato-client-latest;
  };

  # Don't autostart on boot — run `systemctl start cato-client` manually
  systemd.services.cato-client.wantedBy = lib.mkForce [];

  # Restore real DNS when the tunnel goes down.
  # Cato overwrites /etc/resolv.conf with its tunnel resolver (10.254.254.1)
  # and does NOT restore it on exit. Stopping or crashing Cato then leaves
  # resolv.conf pointed at a now-dead address inside the torn-down tunnel, so
  # every lookup (internal + external) fails. ExecStopPost fires on any stop
  # (clean stop OR crash, since Restart=always means a kill just respawns it),
  # regenerating resolv.conf from networking.nameservers via resolvconf, with a
  # hard fallback to NetworkManager's live copy if the dead entry survives.
  systemd.services.cato-client.serviceConfig.ExecStopPost =
    let
      restoreDns = pkgs.writeShellScript "cato-restore-dns" ''
        ${config.networking.resolvconf.package}/bin/resolvconf -u || true
        if ${pkgs.gnugrep}/bin/grep -q '10\.254\.254\.1' /etc/resolv.conf 2>/dev/null; then
          ${pkgs.coreutils}/bin/cp -f /run/NetworkManager/resolv.conf /etc/resolv.conf
        fi
      '';
    in [ "${restoreDns}" ];

  # Cato needs /opt/cato/config to exist and be writable
  systemd.tmpfiles.rules = [
    "d /opt/cato 0755 root cato-client -"
    "d /opt/cato/config 0775 root cato-client -"
  ];

  # Add jake to the cato-client group so cato-sdp works without sudo
  users.users.jake.extraGroups = lib.mkAfter [ "cato-client" ];
}
