{ config, lib, pkgs, ... }:

let
  # Define the configuration namespace
  cfg = config.services.ratatat-listener;
in
{
  # 1. INTERFACE: Define the options users can set
  options.services.ratatat-listener = {
    enable = lib.mkEnableOption "ratatat-listener service";

    package = lib.mkOption {
      type = lib.types.package;
      # If 'ratatat-listener' isn't in standard nixpkgs, replace this default
      # with your specific package derivation, e.g., pkgs.callPackage ./derivations/ratatat.nix {}
      default = pkgs.ratatat-listener or pkgs.hello; 
      description = "The package to use for the ratatat-listener service.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the listener to bind to.";
    };
    
    user = lib.mkOption {
      type = lib.types.str;
      default = "ratatat";
      description = "User account under which the service runs.";
    };
  };

  # 2. IMPLEMENTATION: The config that is generated if 'enable' is true
  config = lib.mkIf cfg.enable {
    
    # Optional: Create a system user for the service if it doesn't exist
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
      description = "Ratatat Listener service user";
    };
    users.groups.${cfg.user} = {};

    # Define the Systemd service
    systemd.services.ratatat-listener = {
      description = "Ratatat Listener Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        # Adjust the command if your binary is named differently
        ExecStart = "${cfg.package}/bin/ratatat-listener --port ${toString cfg.port}";
        
        # Security hardening options (good practice)
        User = cfg.user;
        Group = cfg.user;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
