{ config, pkgs, ... }:
{
  specialisation = {
    egpu.configuration = {
        system.nixos.tags = ["nvidia"];
      };
        };
  services.xserver.videoDrivers = ["nvidia"];
};

  hardware.nvidia = {

   modesetting.enable = true;
powerManagement.enable = false;
    open = false;
nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
#    nvidiaPersistenced = true;
      prime = {
        sync.enable = true;
        allowExternalGpu = true;
        nvidiaBusId = "PCI:130:0:0";
        intelBusId = "PCI:0:2:0";
};
};




}



