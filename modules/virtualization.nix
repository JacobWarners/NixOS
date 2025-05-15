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
    libguestfs
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf = {
      enable = true;
      packages = [
        (pkgs.OVMFFull.override {
          secureBoot = true;
        }).fd
      ];
    };
  };
  # Enable and configure libvirtd service
  #  virtualisation.libvirtd = {
  #    enable = true;
  #    qemu.ovmf = {
  #      enable = true;
  #      (pkgs.OVMFFull.override {
  #        secureBoot = true;
  #        csmSupport = false;
  ##      packages = [pkgs.OVMF.fd];
  #        }).fd
  #    };
  #  };
  #

  #    system.activationScripts.ovmfCopy = {
  #    text = ''
  #      # Create a directory for the OVMF firmware in a writable location.
  #      mkdir -p /run/libvirt/nix-ovmf
  #      rm -rf /run/libvirt/nix-ovmf/*
  #
  #      # Copy the firmware files from the OVMF derivation.
  #      cp ${pkgs.OVMF.fd}/FV/OVMF_CODE.fd /run/libvirt/nix-ovmf/OVMF_CODE.fd
  #      cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd /run/libvirt/nix-ovmf/OVMF_VARS.fd
  #
  #      # (Optional) Set appropriate permissions, though they should be readable.
  #      chmod 444 /run/libvirt/nix-ovmf/OVMF_CODE.fd /run/libvirt/nix-ovmf/OVMF_VARS.fd
  #    '';
  #  };
  #    system.activationScripts.ovmfSecure = {
  #    text = ''
  #      mkdir -p /var/lib/libvirt/firmware
  #      rm -rf /var/lib/libvirt/firmware/*
  #
  #      cp ${pkgs.OVMFFull.fd}/FV/OVMF_CODE.secboot.fd /var/lib/libvirt/firmware/OVMF_CODE.secboot.fd
  #      cp ${pkgs.OVMFFull.fd}/FV/OVMF_VARS.secboot.fd /var/lib/libvirt/firmware/OVMF_VARS.secboot.fd
  #
  #      chmod 444 /var/lib/libvirt/firmware/OVMF_CODE.secboot.fd /var/lib/libvirt/firmware/OVMF_VARS.secboot.fd
  #    '';
  #  };
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

