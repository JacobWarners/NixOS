{ config, lib, pkgs, ... }:

let
  # You can still define variables here for convenience
  user = "ratatat";
  port = 8080;
  # Replace with your actual package if needed, e.g. pkgs.callPackage ...
  pkg = pkgs.ratatat-listener or pkgs.hello; 
in
{
  # --- User Configuration ---
  users.users.${user} = {
    isSystemUser = true;
    group = user;
    description = "Ratatat Listener service user";
  };
  users.groups.${user} = {};

  # --- Service Configuration ---
  # No "mkIf" or "options" needed. It just exists now.
  systemd.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkg}/bin/ratatat-listener --port ${toString port}";
      User = user;
      Group = user;
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
