{ config, pkgs, ... }:

{
  # 1. Enable the Libvirt daemon (the backend)
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # TPM support
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  # 2. Enable the Virt-Manager GUI
  programs.virt-manager.enable = true;

  # 3. System Packages
  environment.systemPackages = with pkgs; [
    libvirt
    qemu
    OVMFFull
    swtpm
  ];

  # 4. Polkit (Critical for Hyprland users)
  # Allows virt-manager to ask for your password when connecting to system libvirt
  security.polkit.enable = true;

  # 5. Enable dconf
  # Virt-manager requires this to store settings (connections, view preferences, etc.)
  programs.dconf.enable = true;
}
