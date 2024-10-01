{ config, pkgs, ... }:

{
  # Install virtualization packages
  environment.systemPackages = with pkgs; [
    qemu_kvm             # QEMU with KVM support
    libvirt              # Libvirt library
    virt-manager         # GUI tool for managing virtual machines
    virtualbox           # VirtualBox virtualization software
    wget                 # Utility to download files from the web
  ];

  # Enable and configure libvirtd service
  virtualisation.libvirtd = {
    enable = true;
    package = pkgs.libvirt;
    qemuRunAsRoot = true;  # Optional: run QEMU as root if needed
  };

  # Enable VirtualBox service
  virtualisation.virtualbox.host.enable = true;

  # Set user permissions
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [
      "wheel"       # For sudo privileges
      "kvm"         # For KVM access
      "libvirtd"    # For libvirt access
      "vboxusers"   # For VirtualBox USB access
    ];
  };

  # Optional: Download Rocky Linux 9 Minimal ISO
  system.activationScripts.downloadRockyLinux = {
    text = ''
      mkdir -p /var/lib/libvirt/boot
      if [ ! -f /var/lib/libvirt/boot/Rocky-9-Minimal.iso ]; then
        echo "Downloading Rocky Linux 9 Minimal ISO..."
        wget -O /var/lib/libvirt/boot/Rocky-9-Minimal.iso \
          https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.2-x86_64-minimal.iso
      fi
    '';
    deps = [];
  };
}

