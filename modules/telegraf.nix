{ config, pkgs, ... }:

let
	secrets = import /home/jake/nixos-config/secrets.nix;
in

{
  services.telegraf = {
    enable = true;
 #This would be for sops#   environmentFiles = [config.sops.secrets.influx_token.path];
    extraConfig = {
      inputs = {
        cpu = {};
        mem = {};
        disk = {};
        net = {};
	};
    outputs = {
      influxdb_v2 = {
        urls = [ "https://influx.root-beards.com" ];
#sops#        token = "$influx_token";
        token =  secrets.influxToken;
        organization = "home";
        bucket = "home";
        };
      };
    };
  };
}
