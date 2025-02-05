{ config, pkgs, ... }:

{
  # Install virtualization packages and additional utilities for Spice
  environment.systemPackages = with pkgs; [
    qemu_kvm         # QEMU with KVM support
    libvirt          # Libvirt library
    virt-manager     # GUI tool for managing virtual machines
    spice-vdagent    # Agent for clipboard sharing and file transfer
    spice            # Spice client and support libraries
    spice-protocol
    spice-gtk
  ];

  # Configure libvirtd to use UEFI with secure boot enabled.
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf = {
      enable = true;
      # Use an override of OVMFFull with secureBoot and TPM support.
      # (Note: In this channel the secure-boot override does not produce distinct file names,
      # so we use .outPath to access its output.)
      packages = [
        (pkgs.OVMFFull.override {
          secureBoot = true;
          tpmSupport = true;
        }).outPath
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

      # Let drv be the overridden OVMFFull with secureBoot and tpmSupport enabled.
      # In this channel, its output files are still named "OVMF_CODE.fd" and "OVMF_VARS.fd",
      # so we copy them and rename them to include the ".secboot.fd" suffix.
      cp ${let drv = pkgs.OVMFFull.override { secureBoot = true; tpmSupport = true; }; in drv.outPath}/FV/OVMF_CODE.fd /var/lib/libvirt/firmware/OVMF_CODE.secboot.fd
      cp ${let drv = pkgs.OVMFFull.override { secureBoot = true; tpmSupport = true; }; in drv.outPath}/FV/OVMF_VARS.fd /var/lib/libvirt/firmware/OVMF_VARS.secboot.fd

      chmod 444 /var/lib/libvirt/firmware/OVMF_CODE.secboot.fd /var/lib/libvirt/firmware/OVMF_VARS.secboot.fd
    '';
  };

  # Enable the Spice agent service.
  services.spice-vdagentd.enable = true;

  # Enable additional video support for Spice.
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

