{ config, pkgs, inputs, ... }:

{
  boot = {
    # This block ensures your AMD graphics driver loads early
    initrd.kernelModules = [ "amdgpu" ];

    # Add this line to force early loading for Plymouth
    initrd.availableKernelModules = [ "amdgpu" ];
    # silence first boot output
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    kernelParams = [
        "quiet"
        "splash"
        "intremap=on"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
    ];

    # plymouth, showing after LUKS unlock
    plymouth.enable = true;
    plymouth.font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
    plymouth.logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
};
}

    };

    # Restore the boot entry limit
    loader.systemd-boot.configurationLimit = 3;

    # Other boot options

    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
