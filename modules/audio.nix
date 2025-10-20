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

    # Use this older, more compatible method to create the sink
    config.pulse = {
      "context.exec" = [
        "load-module module-null-sink sink_name=error_sounds sink_properties=device.description=\"Error Sounds\""
        "load-module module-loopback source=error_sounds.monitor"
      ];
    };

    # jack.enable = true;
  };
}
