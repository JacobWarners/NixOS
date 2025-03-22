# configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/specialisation.nix
    ./modules/hotplugegpu.nix
    ./modules/flatpak.nix
    ./modules/nix.nix
    ./modules/nix-ld.nix
    ./modules/bluray.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    ./modules/egpu.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/global-packages.nix
    ./modules/virtualization.nix
    ./modules/gaming.nix
    ./modules/docker.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      chromium =
        (import
          (builtins.fetchTarball {
            url = "https://github.com/NixOS/nixpkgs/archive/fd40cef8d797670e203a27a91e4b8e6decf0b90c.tar.gz";
            sha256 = "1xxmih8zbxk80m6r0zd5qp6z6a4cxl7n1cmnlhs5wi87n4sfz24w";
          })
          {
            system = "x86_64-linux";
            config.allowUnfree = true;
          }).chromium;
      linuxPackages = prev.linuxPackages.extend (lself: lsuper: {
        nvidia_x11 = (import
          (builtins.fetchTarball {
            url = "https://github.com/NixOS/nixpkgs/archive/fd40cef8d797670e203a27a91e4b8e6decf0b90c.tar.gz";
            sha256 = "1xxmih8zbxk80m6r0zd5qp6z6a4cxl7n1cmnlhs5wi87n4sfz24w";
          })
          { system = "x86_64-linux"; config.allowUnfree = true; }
        ).linuxPackages.nvidia_x11;
      });
    })
  ];

  # Ensure VAAPI support for Intel
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl ];
  };

  system.stateVersion = "24.11";
}
