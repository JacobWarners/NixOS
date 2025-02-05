{ config, pkgs, ... }:

{
  # System packages: virtualization, TPM, and Spice-related tools.
  environment.systemPackages = with pkgs; [
    qemu_kvm         # QEMU with KVM support
    libvirt          # Libvirt library
    virt-manager     # GUI tool for managing VMs
    spice-vdagent    # For clipboard sharing and file transfer (Spice)
    spice            # Spice client and support libraries
    spice-protocol
    spice-gtk
    swtpm            # Software TPM (needed for Windows 11 secure boot)
  ];

  # Configure libvirtd to enable UEFI with secure boot.
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    qemu.ovmf = {
      enable = true;
      # Use the secure‑boot firmware from the OVMFFull package.
      # (If necessary, pin nixpkgs to a known‑good revision such as nixos-24.05.)
      packages = [ pkgs.OVMFFull ];
    };
  };

  # Activation script: Copy the secure‑boot firmware files from the OVMFFull derivation.
  # This script uses find to locate the files named "OVMF_CODE.fd" and "OVMF_VARS.fd"
  # in the OVMFFull output and copies them to /etc/ovmf with stable names.
  system.activationScripts.ovmfStatic = {
    text = ''
      mkdir -p /etc/ovmf
      rm -rf /etc/ovmf/*

      # Find the secure boot firmware files.
      CODE=$(find ${pkgs.OVMFFull} -type f -name "OVMF_CODE.fd" | head -n1)
      VARS=$(find ${pkgs.OVMFFull} -type f -name "OVMF_VARS.fd" | head -n1)

      if [ -z "$CODE" ] || [ -z "$VARS" ]; then
        echo "Error: Could not find secure boot firmware files in ${pkgs.OVMFFull}"
        exit 1
      fi

      cp "$CODE" /etc/ovmf/edk2-x86_64-secure-code.fd
      cp "$VARS" /etc/ovmf/edk2-i386-vars.fd
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

