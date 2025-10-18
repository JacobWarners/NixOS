{ config, pkgs, ... }:

let 
	secrets = import ../.secrets.nix;
in
{
  services.telegraf = {
    enable = true;
    extraConfig = {
      inputs = {
        cpu = {};
        mem = {};
        disk = {};
        net = {};
    outputs = {
      influxdb_v2 = {
        urls = [ "https://influxdb.root-beards.com" ];
        token = secrets.influxToken; 
        organization = "home"";
        bucket = "home";
        };
      };
    };
  };
};
}
