{ config, pkgs, ... }:

let
  interfaceName = "enp0s13f0u1u4"; # Replace with your actual interface name
  cfg = config.sys;
in

{


services.xserver = mkIf (cfg.desktop.enable && cfg.desktop.displayProtocol == "xserver") {
    enable = true;
    displayManager.startx.enable = true;
    # FIXME: eventually check if a laptop
    config = mkAfter ''
      Section "Monitor"
        Identifier "Monitor[1]"
        Modeline "2560x1440_180.00"  735.75  2560 2760 3048 3536  1440 1443 1448 1530 -hsync +vsync
      EndSection

      Section "Device"
        Identifier "Device[0]"
        Driver     "nvidia" 
        BusID      "PCI:130:0:0"
        Option     "AllowExternalGpus" "True"
        Option     "AllowEmptyInitialConfiguration"
      EndSection

      Section "Screen"
        Identifier "Screen-Nvidia[0]"
        Device "Device-nvidia[0]"
        Monitor "Monitor[1]"
      EndSection
    '';

    videoDrivers = [ "nvidia" "modesetting" ];
    libinput = {
      enable = true;
      touchpad = mkIf (cfg.laptop.model != "none") {
        tapping = false;
        naturalScrolling = true;
        # left-click = 1 finger click
        # right-click = 2 finger click
        # middle-click = 3 finger click
        clickMethod = "clickfinger";
        disableWhileTyping = true;
      };
      mouse = {
        tapping = false;
        naturalScrolling = false;
        middleEmulation = false;
        disableWhileTyping = false;
      };
    };
  };






########################################
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

  hardware.nvidia = {

   # Modesetting is required.
   modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
#    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
#    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
#    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaPersistenced = true;

};
# environment.etc."X11/xorg.conf.d/11-nvidia.conf".text = ''
#   Section "Device"
#    Identifier "Device0"
#    Driver "nvidia"
#    BusID "PCI:82:0:0"
#    Option "AllowEmptyInitialConfiguration" "true"
#    Option "AllowExternalGpus" "true"
#    Option "PrimaryGPU" "true"
#  EndSection

#   Section "Screen"
#   Identifier "Screen0"
#   Device "Device0" 
#   Monitor "Monitor0"
# EndSection

#   Section "Monitor"
#     Identifier "Monitor0"
# EndSection
#'';



  environment.systemPackages = with pkgs; [ ethtool ];

  systemd.services.ethtool-config = {
    description = "Apply ethtool settings to disable Interrupt Moderation";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -C ${interfaceName} rx-usecs 0";
    };
  };
}



