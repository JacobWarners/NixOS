{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc        # VLC Media Player
    libbluray  # Library for Blu-ray playback
    libaacs    # Library for handling AACS DRM
    makemkv    # Optional: For advanced Blu-ray decryption
  ];

  # Add a script to download the AACS keys (KEYDB.cfg) automatically
  systemd.services.downloadAACSKeys = {
    description = "Download AACS KeyDB.cfg for Blu-ray playback";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -o /home/${config.users.users.yourusername.name}/.config/aacs/KEYDB.cfg https://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg";
      ExecStartPost = "/bin/chown ${config.users.users.yourusername.name}:${config.users.users.yourusername.name} /home/${config.users.users.yourusername.name}/.config/aacs/KEYDB.cfg";
      ExecStartPost = "/bin/chmod 600 /home/${config.users.users.yourusername.name}/.config/aacs/KEYDB.cfg";
    };
  };
}
