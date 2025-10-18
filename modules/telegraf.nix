{ config, pkgs, ... }:

{
  services.telegraf = {
    enable = true;
    environmentFiles = [config.sops.secrets.influx_token.path];
    extraConfig = {
      inputs = {
        cpu = {};
        mem = {};
        disk = {};
        net = {};
    outputs = {
      influxdb_v2 = {
        urls = [ "https://influxdb.root-beards.com" ];
        token = "$influx_token";
        organization = "home";
        bucket = "home";
        };
      };
    };
  };
};
}
