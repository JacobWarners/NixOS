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

    # This is the correct option for your system, as shown
    # in your search results.
    extraConfig.pipewire-pulse = ''
      # Create a virtual sink for error sounds
      load-module module-null-sink sink_name=error_sounds sink_properties=device.description="Error_Sounds"

      # Route its output back to the default hardware sink
      load-module module-loopback source=error_sounds.monitor sink=@DEFAULT_SINK@
    '';

    # jack.enable = true;
  };
}
