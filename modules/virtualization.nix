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

  # Configure libvirtd:
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    qemu.ovmf = {
      enable = true;
      # Use the secure-boot firmware; note that the new option is plural.
      packages = [ pkgs.OVMFFull ];
    };
  };

  # Publish secure-boot firmware files to /etc/ovmf.
  # These files will then be available at /etc/ovmf/edk2-x86_64-secure-code.fd and
  # /etc/ovmf/edk2-i386-vars.fd, which you can reference in your VM XML.
  environment.etc."ovmf/edk2-x86_64-secure-code.fd" = {
    source = "${pkgs.OVMFFull}/share/qemu/edk2-x86_64-secure-code.fd";
  };

  environment.etc."ovmf/edk2-i386-vars.fd" = {
    source = "${pkgs.OVMFFull}/share/qemu/edk2-i386-vars.fd";
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

