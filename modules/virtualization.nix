i{ config, pkgs, lib, ... }:

{
  # Enable and configure the libvirtd service for virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu;
    extraOptions = ''
      unix_sock_group = "libvirt"
      unix_sock_ro_perms = "0777"
      unix_sock_rw_perms = "0770"
    '';
    settings = {
      network.defaultAutostart = true;  # Ensure default network starts automatically
      user = "libvirt-qemu";           # User that libvirt runs as
      group = "libvirt";               # Group for managing libvirt permissions
    };
  };

  # Enable virt-manager for managing virtual machines
  programs.virt-manager.enable = true;

  # Configure user permissions for libvirtd
  users.users.jake = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];  # Ensure user 'jake' is in the libvirtd group
  };

  # Configure networking for libvirt
  networking = {
    enable = true;
    useDHCP = true;
    bridges.br0 = {
      interfaces = [ "eth0" ];   # Replace "eth0" with your actual network interface name
    };
    bridges.br0.ipv4.addresses = [ { address = "192.168.122.1"; prefixLength = 24; } ];
  };

  # Enable PipeWire and WirePlumber for audio management (Optional)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.wireplumber.enable = true;

  # Ensure required packages are installed
  environment.systemPackages = with pkgs; [
    virt-manager          # Virt-manager for VM management
    libvirt               # Libvirt for virtualization
    qemu                  # QEMU as the hypervisor
    spice-gtk             # Spice for enhanced graphics in VMs
    xdg-desktop-portal    # XDG Portal for inter-process communication
    xdg-desktop-portal-wlr  # XDG Portal for Wayland support
    xdg-desktop-portal-hyprland  # XDG Portal for Hyprland compatibility
  ];

  # Configure XWayland for Wayland compatibility (Optional)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Set environment variables for GTK applications on Wayland (Optional)
  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";  # Enable Wayland support in Firefox
  };
}

