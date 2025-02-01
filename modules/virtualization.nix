{ config, pkgs, ... }:

{
  # Install virtualization packages and additional utilities for Spice
  environment.systemPackages = with pkgs; [
    qemu_kvm # QEMU with KVM support
    libvirt # Libvirt library
    virt-manager # GUI tool for managing virtual machines
    spice-vdagent # Agent to enable clipboard sharing and file transfer
    spice # Spice client and support libraries
    spice-protocol
    spice-gtk
  ];

  # Enable and configure libvirtd service
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf = {
      enable = true;
      packages = [pkgs.OVMF.fd];
    };
  };


  system.activationScripts.ovmfSymlink = {
    text = ''
      mkdir -p /run/current-system/sw/share/qemu
      # Remove any existing OVMF directory, then symlink the FV directory from the derivation.
      rm -rf /run/current-system/sw/share/qemu/OVMF
      ln -s ${pkgs.OVMF.fd}/FV /run/current-system/sw/share/qemu/OVMF
    '';
  };



  # Enable Spice services for clipboard sharing and file transfer support
  services.spice-vdagentd.enable = true;

  # Enable necessary hardware acceleration and video support for Spice
  hardware.graphics = {
    extraPackages = with pkgs; [
      vaapiIntel # VAAPI for Intel GPUs
      vaapiVdpau # VDPAU/VAAPI interoperability
    ];
  };

  # Set user permissions
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # For sudo privileges
      "kvm" # For KVM access
      "libvirt" # For libvirt access
    ];
  };
}

