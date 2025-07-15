{ config, pkgs, ... }:

let
  logoutScript = pkgs.writeScript "logout-script.sh" ''
    #!/usr/bin/env bash
    loginctl list-sessions --no-legend | while read session uid user seat rest; do
      if [ "$uid" -ne 0 ]; then
        loginctl terminate-session "$session"
      fi
    done
  '';
in
{
  services.udev.extraRules = ''
    ACTION=="bind", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="1", ATTRS{vendor_name}=="NVIDIA", ATTRS{device_name}=="GeForce RTX 3060", ENV{SYSTEMD_WANTS}+="logout-on-device.service"
  '';

  systemd.services.logout-on-device = {
    description = "Logout user when eGPU is connected via Thunderbolt";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${logoutScript}";
    };
  };
}

