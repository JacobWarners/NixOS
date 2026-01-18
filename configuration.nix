{ config, pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ./modules/sonic-waygame.nix
    #    ./modules/virtual-audio-sink.nix
    ./modules/polkit.nix
    ./modules/telegraf.nix
    #    ./modules/undock-service.nix
    #    ./modules/specialisation.nix
    #    ./modules/hotplugegpu.nix
    ./modules/hyprland.nix
    ./modules/auto-backup-nas.nix
    ./modules/amd-performance.nix
    #    ./modules/ratatat-listener.nix
    ./modules/amd.nix
    #    ./modules/transcriber.nix
    #    ./modules/flatpak.nix
    ./modules/nix.nix
    ./modules/nix-ld.nix
    ./modules/bluetooth.nix
    #    ./modules/bluray.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    #    ./modules/nvidia-egpu.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/unfree.nix
    ./modules/global-packages.nix
    ./modules/virtualization.nix
    ./modules/gaming.nix
    ./modules/docker.nix
    # Add any other modules you have
  ];

  ##############SOPS###################

  #  # 1. Point sops-nix to the host's private key for decryption
  #  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  #
  #  # 2. Define your secrets
  #  sops.secrets = {
  #    influx_token = {
  #      sopsFile = ./secrets.yaml;
  #      key = "influx_token";
  #      owner = config.services.telegraf.user;
  #    };
  #
  #    "ssh_key" = {
  #      sopsFile = ./secrets.yaml;
  #      key = "ssh_private_key";
  #      path = "/home/jake/.ssh/id_ed25519";
  #      owner = "jake";
  #      mode = "0600";
  #    };
  #  };
  #
  #####################################
  #Overlay
  #######################################
  nixpkgs.overlays = [
    (self: super: {
      notion-app-enhanced = super.notion-app-enhanced.overrideAttrs (oldAttrs: {
        # This 'postPatch' command runs after the source code is unpacked
        # but before it's built.
        postPatch = ''
          # Find the main package.json and disable the auto-updater script.
          # This prevents the app from ever trying to check for updates.
          substituteInPlace resources/app.asar.unpacked/package.json \
            --replace '"autoUpdater": "electron-updater.js"' '"autoUpdater": "echo.js"'
        '';
      });
    })
  ];
  ###################################
  system.stateVersion = "25.05";
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.hyprland.enable = true;
  # In /etc/nixos/configuration.nix

  systemd.services."home-manager-jake".after = [ "graphical-session-pre.target" ];

  # Global settings can be added here if necessary

}

