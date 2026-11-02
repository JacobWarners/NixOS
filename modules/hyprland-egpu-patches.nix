# Two small aquamarine fixes for eGPU hot-(un)plug under Hyprland. Written
# against aquamarine 0.11.0 (nixos-26.05), submitted upstream; see
# ~/home-ai/infra/egpu-dock/README.md for the failure analysis.
#
#  0001  initMgpu(): fall back to the GBM-platform renderer when the EGL device
#        lookup fails (GPU re-plugged after Hyprland started -> Mesa's cached
#        device list points at the old card number -> no renderer -> black).
#  0002  on GPU removal, disconnect all connectors before dropping the backend
#        (surprise unplug otherwise leaves ghost outputs that crash clients
#        when enabled).
#
# Self-retiring: if nixpkgs moves aquamarine off 0.11.0 the patches are skipped
# with a trace and plain pkgs.aquamarine is used. The egpu-dock scripts work
# either way, they just cannot recover a cable yank without the patches.
{ lib, ... }:

let
  patchedVersion = "0.11.0";
in
{
  nixpkgs.overlays = [
    (final: prev:
      let
        v = prev.aquamarine.version;
        patched = prev.aquamarine.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./patches/aquamarine/0001-drm-gbm-fallback-for-mgpu-renderer.patch
            ./patches/aquamarine/0002-drm-disconnect-connectors-on-gpu-remove.patch
          ];
        });
      in
      {
        aquamarine =
          if v == patchedVersion then patched
          else builtins.trace "hyprland-egpu-patches: aquamarine ${v} != ${patchedVersion}, eGPU patches skipped (cable yank needs logout again)" prev.aquamarine;
      })
  ];
}
