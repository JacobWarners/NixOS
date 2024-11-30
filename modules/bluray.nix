{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.vlc.override {
      libbluray = pkgs.libbluray;
    })
    libaacs
    makemkv
  ];

  # Systemd service for AACS keys
  systemd.services.downloadAACSKeys = {
    description = "Download AACS KeyDB.cfg for Blu-ray playback";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -o /home/${config.users.users.jake.name}/.config/aacs/KEYDB.cfg https://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg";
      ExecStartPost = "${pkgs.bash}/bin/bash -c 'chown ${config.users.users.jake.name}:${config.users.users.jake.name} /home/${config.users.users.jake.name}/.config/aacs/KEYDB.cfg && chmod 600 /home/${config.users.users.jake.name}/.config/aacs/KEYDB.cfg'";
    };
  };
}

