{ config, pkgs, ... }:

{
  # eGPU hot-plugging service
  systemd.services.egpu-hotplug = {
    description = "eGPU Hotplug Service";
    wantedBy = [ "multi-user.target" ];
    script = ''
      #!/bin/bash
      # Your eGPU setup script here
      # This script should handle eGPU detection and configuration
    '';
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash /etc/egpu-setup.sh";
    };
  };

  # Place the eGPU setup script in /etc/
  environment.etc."egpu-setup.sh".text = ''
    #!/bin/bash
    # Your eGPU setup script content
  '';
}

