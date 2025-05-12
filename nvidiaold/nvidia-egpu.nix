{ config, pkgs, ... }:

{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", RUN+="${pkgs.bash}/bin/bash /etc/egpu-setup.sh"
    ACTION=="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", RUN+="${pkgs.bash}/bin/bash /etc/egpu-teardown.sh"
  '';

  environment.etc."egpu-setup.sh".text = ''
    #!/bin/bash
    xrandr --setprovideroutputsource modesetting NVIDIA-0
    xrandr --auto
  '';
  environment.etc."egpu-setup.sh".mode = "0755";

  environment.etc."egpu-teardown.sh".text = ''
    #!/bin/bash
    xrandr --setprovideroutputsource modesetting modesetting
    xrandr --auto
  '';
  environment.etc."egpu-teardown.sh".mode = "0755";
}

