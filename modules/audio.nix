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

    # This structure matches the NixOS documentation you provided.
    # We create a virtual config file ("99-custom-sinks.conf")
    # and place the configuration inside it.
    extraConfig.pipewire-pulse = {
      "99-custom-sinks.conf" = {
        "context.exec" = [
          "load-module module-null-sink sink_name=error_sounds sink_properties=device.description=\"Error_Sounds\""
          "load-module module-loopback source=error_sounds.monitor sink=@DEFAULT_SINK@"
        ];
      };
    };

    # jack.enable = true;
  };
}

