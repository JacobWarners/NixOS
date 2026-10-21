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
    # Floor the graph quantum: Tibia's ALSA client requests 64 samples (1.3 ms),
    # which drags every stream to buffers the CPU can't service under load —
    # constant underruns = crackle/pops on all audio (found 2026-10-21).
    # 256 @ 48 kHz = 5.3 ms, inaudible latency for games.
    extraConfig.pipewire."92-min-quantum" = {
      "context.properties"."default.clock.min-quantum" = 256;
    };

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
