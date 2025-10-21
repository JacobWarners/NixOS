# In your configuration.nix or a separate module

{ config, pkgs, ... }:

{
  # Ensure PipeWire and the PulseAudio compatibility layer are enabled.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Use the modern configuration point for the PipeWire-Pulse server.
  services.pipewire.pulse.extraConfig = ''
    # Create the virtual sink
    context.modules = [
      {
        name = lib.pipewire.modules.protocol-native
      }
      {
        name = lib.pipewire.modules.protocol-pulse
      }
      # Load the null-sink module
      {
        name = lib.pipewire.modules.module-null-sink
        args = {
          sink.name = "error_sounds"
          sink.properties = {
            node.description = "Virtual Sink for Error Sounds"
          }
        }
      }
      # Load the loopback module to hear the sink's output
      {
        name = lib.pipewire.modules.module-loopback
        args = {
          capture.props = {
            node.target = "error_sounds"
            audio.position = "FL,FR"
          }
          playback.props = {
            media.class = "Audio/Sink"
            audio.position = "FL,FR"
          }
        }
      }
    ]
  '';
}
