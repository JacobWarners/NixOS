{ config, pkgs, ... }:

{
  # Install the necessary packages
  environment.systemPackages = with pkgs; [
    vlc        # VLC media player
    libbluray  # Library for Blu-ray support
    libaacs    # Library for AACS decryption
    makemkv    # MakeMKV for advanced Blu-ray decryption
  ];

  # Systemd service to download AACS keys
  systemd.services.downloadAACSKeys = {
    description = "Download AACS KeyDB.cfg for Blu-ray playback";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -o /home/jake/.config/aacs/KEYDB.cfg https://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg";
      ExecStartPost = "${pkgs.bash}/bin/bash -c 'chown jake:jake /home/jake/.config/aacs/KEYDB.cfg && chmod 600 /home/jake/.config/aacs/KEYDB.cfg'";
    };
  };
}

