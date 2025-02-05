{
  description = "Secure boot configuration for virtualization on NixOS";

  inputs = {
    # Pin to a reputable revision known to produce secure-boot firmware.
    # Replace this URL with a commit or channel that you know works.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05"; 
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        # This is our system configuration.
        packages = {};
        # Replace or add to your existing configuration.nix
        configuration = { config, pkgs, ... }: {
          # System packages
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
              # Use the secure boot firmware from the OVMFFull package.
              packages = [ pkgs.OVMFFull ];
            };
          };

          # Activation script to publish secure boot firmware files directly to /etc/ovmf.
          system.activationScripts.ovmfStatic = {
            text = ''
              mkdir -p /etc/ovmf
              rm -rf /etc/ovmf/*

              # Copy secure boot firmware files from OVMFFull.
              # These paths are based on the standard output of OVMFFull.
              cp ${pkgs.OVMFFull}/share/qemu/edk2-x86_64-secure-code.fd /etc/ovmf/edk2-x86_64-secure-code.fd
              cp ${pkgs.OVMFFull}/share/qemu/edk2-i386-vars.fd /etc/ovmf/edk2-i386-vars.fd
              chmod 444 /etc/ovmf/edk2-x86_64-secure-code.fd /etc/ovmf/edk2-i386-vars.fd
            '';
          };

          # Enable the Spice agent service.
          services.spice-vdagentd.enable = true;

          # Additional hardware acceleration for graphics (optional for Spice).
          hardware.graphics.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau ];

          # Set user permissions.
          users.users.jake = {
            isNormalUser = true;
            extraGroups = [ "wheel" "kvm" "libvirt" ];
          };

          # (Other parts of your configuration go here)
        };
      });
}

