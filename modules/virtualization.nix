{ config, pkgs, ... }:

{
  # Install virtualization packages and additional utilities for Spice
  environment.systemPackages = with pkgs; [
    qemu_kvm         # QEMU with KVM support
    libvirt          # Libvirt library
    virt-manager     # GUI tool for managing virtual machines
    spice-vdagent    # Agent to enable clipboard sharing and file transfer
    spice            # Spice client and support libraries
    spice-protocol
    spice-gtk
  ];

  # Configure libvirtd to use UEFI with secure boot enabled.
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf = {
      enable = true;
      packages = [
        (pkgs.OVMFFull.override {
          secureBoot = true;
          tpmSupport = true;  # Set to false if TPM support is not required.
        })
      ];
    };
  };

  ##############################
  # Activation Script: Standard Firmware (Non‑Secure)
  ##############################
  system.activationScripts.ovmfCopy = {
    text = ''
      mkdir -p /run/libvirt/nix-ovmf
      rm -rf /run/libvirt/nix-ovmf/*
      cp ${pkgs.OVMF.fd}/FV/OVMF_CODE.fd /run/libvirt/nix-ovmf/OVMF_CODE.fd
      cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd /run/libvirt/nix-ovmf/OVMF_VARS.fd
      chmod 444 /run/libvirt/nix-ovmf/OVMF_CODE.fd /run/libvirt/nix-ovmf/OVMF_VARS.fd
    '';
  };

  ##############################
  # Activation Script: Secure Boot Firmware
  ##############################
  system.activationScripts.ovmfSecure = {
    text = ''
      mkdir -p /var/lib/libvirt/firmware
      rm -rf /var/lib/libvirt/firmware/*

      # Copy files from the secure-boot override derivation.
      # Note: In your channel, the secure-boot override still outputs files named "OVMF_CODE.fd" and "OVMF_VARS.fd".
      cp ${pkgs.OVMFFull.override { secureBoot = true; tpmSupport = true; } }/FV/OVMF_CODE.fd /var/lib/libvirt/firmware/OVMF_CODE.secboot.fd
      cp ${pkgs.OVMFFull.override { secureBoot = true; tpmSupport = true; } }/FV/OVMF_VARS.fd /var/lib/libvirt/firmware/OVMF_VARS.secboot.fd

      chmod 444 /var/lib/libvirt/firmware/OVMF_CODE.secboot.fd /var/lib/libvirt/firmware/OVMF_VARS.secboot.fd
    '';
  };

  # Enable the Spice agent service.
  services.spice-vdagentd.enable = true;

  # Enable necessary hardware acceleration and video support for Spice.
  hardware.graphics = {
    extraPackages = with pkgs; [ vaapiIntel vaapiVdpau ];
  };

  # Set user permissions for virtualization access.
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [
      "wheel"   # For sudo privileges.
      "kvm"     # For KVM access.
      "libvirt" # For libvirt access.
    ];
  };
}

