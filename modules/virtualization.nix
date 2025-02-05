{ config, pkgs, ... }:

{
  # Install virtualization packages and additional utilities.
  environment.systemPackages = with pkgs; [
    qemu_kvm         # QEMU with KVM support
    libvirt          # Libvirt library
    virt-manager     # GUI tool for managing VMs
    spice-vdagent    # For clipboard sharing and file transfer in Spice
    spice            # Spice client and support libraries
    spice-protocol
    spice-gtk
    swtpm            # Software TPM (needed for Windows 11 secure boot)
  ];

  # Configure libvirtd: enable TPM and UEFI with secure boot.
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    qemu.ovmf = {
      enable = true;
      # Use the secure boot firmware from OVMFFull.
      # (Ensure your channel revision produces secure‑boot–capable firmware.)
      packages = [ pkgs.OVMFFull ];
    };
  };

  # Activation script to publish secure boot firmware files directly to /etc/ovmf.
  # This bypasses broken static symlinks.
  system.activationScripts.ovmfStatic = {
    text = ''
      mkdir -p /etc/ovmf
      rm -rf /etc/ovmf/*

      # Copy the secure-boot firmware files from OVMFFull.
      # Adjust these paths if your OVMFFull derivation outputs files under a different path.
      cp ${pkgs.OVMFFull}/share/qemu/edk2-x86_64-secure-code.fd /etc/ovmf/edk2-x86_64-secure-code.fd
      cp ${pkgs.OVMFFull}/share/qemu/edk2-i386-vars.fd /etc/ovmf/edk2-i386-vars.fd

      chmod 444 /etc/ovmf/edk2-x86_64-secure-code.fd /etc/ovmf/edk2-i386-vars.fd
    '';
  };

  # Enable the Spice agent service.
  services.spice-vdagentd.enable = true;

  # Additional hardware acceleration for graphics.
  hardware.graphics.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau ];

  # Set user permissions.
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [ "wheel" "kvm" "libvirt" ];
  };
}

