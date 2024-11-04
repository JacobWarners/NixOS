{ config, pkgs, ... }:

{
  # Base configuration...

  specialisation = {
    nvidia = {
      config = {
        system.nixos.tags = ["nvidia"];

        boot = {
          # Optionally blacklist the integrated graphics module
          blacklistedKernelModules = [ "i915" ];
          kernelParams = [ "module_blacklist=i915" ];
        };

        services.xserver = {
          enable = true;
          videoDrivers = [ "nvidia" ];
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;
          displayManager.gdm.wayland = false;

          deviceSection = ''
            Section "Device"
              Identifier "Nvidia GPU"
              Driver "nvidia"
              BusID "PCI:130:0:0" # Replace with your actual BusID
              Option "AllowEmptyInitialConfiguration"
            EndSection
          '';
        };

        hardware.nvidia = {
          modesetting.enable = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
      };
    };
  };
}

