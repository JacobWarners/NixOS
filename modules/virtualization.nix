{ config, pkgs, ... }:

{
  # Install virtualization packages and required utilities.
  environment.systemPackages = with pkgs; [
    qemu_kvm         # QEMU with KVM support
    libvirt          # Libvirt library
    virt-manager     # GUI tool for managing VMs
    spice-vdagent    # Clipboard sharing and file transfer (Spice)
    spice            # Spice client and support libraries
    spice-protocol
    spice-gtk
    swtpm            # Software TPM (required for Windows 11 secure boot)
  ];

  # Configure libvirtd to enable UEFI with secure boot.
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    qemu.ovmf = {
      enable = true;
      # Use the secure boot firmware from the OVMFFull package.
      # (Make sure your channel revision supports secure boot via OVMFFull.)
      packages = [ pkgs.OVMFFull ];
    };
  };

  # (Optional) You can use the default activation provided by NixOS,
  # which publishes firmware files under /run/current-system/sw/share/qemu/OVMF.
  # Verify with:
  #   ls -l /run/current-system/sw/share/qemu/OVMF/FV/
  #
  # If those files exist, you can use them directly in your VM XML.
  #
  # You may also add an activation script if needed, for example:
  #
  # system.activationScripts.ovmfCopy = {
  #   text = ''
  #     mkdir -p /run/libvirt/nix-ovmf
  #     rm -rf /run/libvirt/nix-ovmf/*
  #     cp ${pkgs.OVMF.fd}/FV/OVMF_CODE.fd /run/libvirt/nix-ovmf/OVMF_CODE.fd
  #     cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd /run/libvirt/nix-ovmf/OVMF_VARS.fd
  #     chmod 444 /run/libvirt/nix-ovmf/OVMF_CODE.fd /run/libvirt/nix-ovmf/OVMF_VARS.fd
  #   '';
  # };

  # Enable the Spice agent service.
  services.spice-vdagentd.enable = true;

  # Optional graphics acceleration for Spice.
  hardware.graphics.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau ];

  # Set user permissions (adjust username if needed).
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [ "wheel" "kvm" "libvirt" ];
  };
}

