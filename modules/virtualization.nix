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
      # (Ensure your nixpkgs channel revision supports secure boot or pin to a known-good revision.)
      packages = [ pkgs.OVMFFull ];
    };
  };

  # Activation script to publish secure boot firmware files into /etc/ovmf.
  # This script will copy files from /root/secure-ovmf (which you must populate manually)
  # to /etc/ovmf so that your VM XML can reference them.
  system.activationScripts.ovmfStatic = {
    text = ''
      mkdir -p /etc/ovmf
      rm -rf /etc/ovmf/*

      # Check that the source files exist before copying.
      test -f /root/secure-ovmf/OVMF_CODE.secboot.fd || { echo "Error: /root/secure-ovmf/OVMF_CODE.secboot.fd not found" && exit 1; }
      test -f /root/secure-ovmf/OVMF_VARS.secboot.fd || { echo "Error: /root/secure-ovmf/OVMF_VARS.secboot.fd not found" && exit 1; }

      cp /root/secure-ovmf/OVMF_CODE.secboot.fd /etc/ovmf/edk2-x86_64-secure-code.fd
      cp /root/secure-ovmf/OVMF_VARS.secboot.fd /etc/ovmf/edk2-i386-vars.fd
      chmod 444 /etc/ovmf/edk2-x86_64-secure-code.fd /etc/ovmf/edk2-i386-vars.fd
    '';
  };

  # Enable the Spice agent service.
  services.spice-vdagentd.enable = true;

  # Additional hardware acceleration for graphics (optional for Spice).
  hardware.graphics.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau ];

  # Set user permissions (adjust your username if needed).
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [ "wheel" "kvm" "libvirt" ];
  };
}

