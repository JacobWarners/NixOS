{ config, pkgs, ... }:

{
  # 1. Enable the Libvirt daemon
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # 2. Enable Virt-Manager
  programs.virt-manager.enable = true;

  # 3. System Packages
  environment.systemPackages = with pkgs; [
    libvirt
    qemu
    swtpm
    polkit_gnome # The missing piece: provides the password popup
  ];

  # 4. Polkit Service
  security.polkit.enable = true;

  # 5. Autostart the Polkit Agent (The Fix)
  # This creates a systemd service that runs automatically for your user
  # so you don't need to add messy paths to hyprland.conf
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # 6. Enable dconf (Required for virt-manager to save settings)
  programs.dconf.enable = true;
}
