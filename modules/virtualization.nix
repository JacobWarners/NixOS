{ config, pkgs, ... }:

{
  # 1. Enable the Libvirt daemon (the backend)
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # Enable TPM for Windows 11 support
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
  # 'libvirt' provides 'virsh' which your shell script needs
  environment.systemPackages = with pkgs; [
    libvirt
    qemu
    OVMFFull  # UEFI firmware
    swtpm     # TPM emulation
  ];

  # 4. Polkit (Required for Hyprland/Window Managers)
  # Without this, virt-manager will fail to authenticate because there is no 
  # graphical password prompt agent running by default in raw Hyprland.
  security.polkit.enable = true;
  
  # Optional: If you use a dark theme, force GTK apps (like virt-manager) 
  # to use it. Remove if you handle GTK theming elsewhere.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
