{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Wrapper script for VLC
    (pkgs.writeShellScriptBin "vlc" ''
      #!${pkgs.bash}/bin/bash
      export LD_LIBRARY_PATH=${pkgs.libaacs}/lib:${pkgs.libbluray}/lib:$LD_LIBRARY_PATH
      exec ${pkgs.vlc}/bin/vlc "$@"
    '')
    makemkv
  ];

  # Systemd service to download AACS keys
  #  systemd.services.downloadAACSKeys = {
  #    description = "Download AACS KeyDB.cfg for Blu-ray playback";
  #    wantedBy = [ "multi-user.target" ];
  #    serviceConfig = {
  #      Type = "oneshot";
  #      ExecStart = ''
  #        ${pkgs.curl}/bin/curl -o /home/jake/.config/aacs/KEYDB.cfg https://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg
  #      '';
  #      ExecStartPost = ''
  #        ${pkgs.bash}/bin/bash -c 'chown jake:jake /home/jake/.config/aacs/KEYDB.cfg && chmod 600 /home/jake/.config/aacs/KEYDB.cfg'
  #      '';
}
#  };
#}

