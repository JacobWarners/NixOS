{ config, pkgs, ... }:

{
  # Install virtualization packages and additional utilities for Spice
  environment.systemPackages = with pkgs; [
    qemu_kvm             # QEMU with KVM support
    libvirt              # Libvirt library
    virt-manager         # GUI tool for managing virtual machines
    spice-vdagent        # Agent to enable clipboard sharing and file transfer
    spice                # Spice client and support libraries
    spice-protocol
    spice-gtk
  ];

  # Enable and configure libvirtd service
  virtualisation.libvirtd = {
    enable = true;
    hooks.daemons = true;
    ovmf.enable = true;
    ovmf.packges = true;
  };

  # Enable Spice services for clipboard sharing and file transfer support
  services.spice-vdagentd.enable = true;

  # Enable necessary hardware acceleration and video support for Spice
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel          # VAAPI for Intel GPUs
      vaapiVdpau          # VDPAU/VAAPI interoperability
    ];
  };

  # Set user permissions
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [
      "wheel"       # For sudo privileges
      "kvm"         # For KVM access
      "libvirt"     # For libvirt access
    ];
  };
}

