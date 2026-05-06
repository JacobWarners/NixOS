{ config, lib, pkgs, ... }:
{
security.polkit.extraConfig = ''
  polkit.addRule(function(action, subject) {
    // Rule for CoreCtrl
    if ((action.id == "org.corectrl.helper.init" ||
         action.id == "org.corectrl.helperkiller.init") &&
        subject.isInGroup("wheel")) {
          return polkit.Result.YES;
    }

    // Rule for nmcli, checking BOTH the symlink and the real store path
    if (action.id == "org.freedesktop.policykit.exec" &&
        subject.isInGroup("wheel") &&
        (action.lookup("program") == "'' + pkgs.networkmanager + ''/bin/nmcli" ||
         action.lookup("program") == "/run/current-system/sw/bin/nmcli")) {
      return polkit.Result.YES;
    }

    // Rule: allow wheel users to start/stop the apartment WireGuard tunnel
    // (wg-quick-apartment.service) without a password prompt. Used by the
    // Waybar VPN toggle script.
    if (action.id == "org.freedesktop.systemd1.manage-units" &&
        subject.isInGroup("wheel")) {
      var unit = action.lookup("unit");
      if (unit == "wg-quick-apartment.service") {
        var verb = action.lookup("verb");
        if (verb == "start" || verb == "stop" || verb == "restart") {
          return polkit.Result.YES;
        }
      }
    }
  });

  '';
} 
