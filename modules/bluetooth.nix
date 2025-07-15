{
  environment.systemPackages = with pkgs; [
    bluez # Bluetooth utilities
    blueman # GUI Bluetooth manager (optional)
    pipewire # PipeWire itself
    wireplumber # Session manager for PipeWire
    pipewire-pulse # PulseAudio compatibility for PipeWire
    pipewire-alsa # ALSA support for PipeWire
    pipewire-jack # JACK support for PipeWire
    pipewire-media-session # Manages Bluetooth audio profiles
  ];

  services.bluetooth = {
    enable = true;
    extraConfig = ''
      AutoEnable=true
    '';
  };

  services.dbus.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # PipeWire service setup
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
}

