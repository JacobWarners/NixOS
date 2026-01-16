{ config, pkgs, ... }:

{
  # 1. Enable the Libvirt daemon
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # TPM support (Essential for Windows 11)
      # REMOVED: ovmf = { ... } (This is now handled automatically by NixOS)
    };
  };

  # 2. Enable Virt-Manager
  programs.virt-manager.enable = true;

  # 3. System Packages
  environment.systemPackages = with pkgs; [
    libvirt
    qemu
    swtpm
  ];

  # 4. Polkit (Critical for Hyprland/WM authentication)
  security.polkit.enable = true;

  # 5. Enable dconf (Required for virt-manager to save settings)
  programs.dconf.enable = true;
}
