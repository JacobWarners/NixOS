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
    # jack.enable = true;

    # PipeWire 1.6 (26.05 snapshot 2026-09-01) enabled UCM split-PCM sinks by
    # default; on this Framework 13 AMD that made the speaker sink quiet
    # (needed >100% volume) and garbled. Disabling split restores the classic
    # analog-stereo path. Verified working 2026-10-21 via user drop-in;
    # retest without this after a future pipewire/alsa-ucm-conf bump.
    wireplumber.extraConfig."50-disable-ucm-split" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "device.name" = "~alsa_card.*"; } ];
          actions.update-props."api.alsa.split-enable" = false;
        }
      ];
    };
  };
}
