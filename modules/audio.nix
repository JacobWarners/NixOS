{ config, pkgs, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;

    # Final diagnostic test:
    # We are ONLY loading the null-sink to see if it works by itself.
    extraConfig.pipewire-pulse = {
      "99-custom-sinks.conf" = {
        "context.exec" = [
          "load-module module-null-sink sink_name=error_sounds"
        ];
      };
    };

    # jack.enable = true;
  };
}
