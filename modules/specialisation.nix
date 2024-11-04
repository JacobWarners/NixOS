{ config, pkgs, ... }:

{

  specialisation = {
    egpu.configuration = {
        system.nixos.tags = ["nvidia"];

        boot = {
          # Optionally blacklist the integrated graphics module
          blacklistedKernelModules = [ "i915" ];
          kernelParams = [ "module_blacklist=i915" ];
        };
  services.xserver.videoDrivers = ["nvidia"];
};
};
}

