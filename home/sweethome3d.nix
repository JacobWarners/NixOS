{ config, pkgs, ... }:

# Sweet Home 3D + Hyprland smoothness fixes.
# Java Swing/JOGL on a tiling Wayland WM is sluggish unless reparenting is
# disabled and 2D is GPU-accelerated. This wraps the launcher with the right
# env and adds window rules to stop XWayland recompositing churn.

let
  sweethome3d-wrapped = pkgs.writeShellScriptBin "sweethome3d" ''
    # Fixes blank/slow Swing windows on tiling WMs (Hyprland/sway/i3)
    export _JAVA_AWT_WM_NONREPARENTING=1
    # GPU-accelerate the 2D plan view (the laggy part). Drop if rendering glitches.
    export JAVA_TOOL_OPTIONS="-Dsun.java2d.opengl=true ''${JAVA_TOOL_OPTIONS:-}"
    exec ${pkgs.sweethome3d.application}/bin/sweethome3d "$@"
  '';
in
{
  home.packages = [ sweethome3d-wrapped ];

  # Window rules: kill blur/animations/transparency for the XWayland window so
  # Hyprland stops re-compositing it every frame. Class confirmed via
  # `hyprctl clients | grep -i class` — adjust the regex if it differs.
  wayland.windowManager.hyprland.extraConfig = ''
    # --- Sweet Home 3D ---
    windowrulev2 = noblur, class:^(.*[Ss]weet[Hh]ome3[Dd].*)$
    windowrulev2 = noanim, class:^(.*[Ss]weet[Hh]ome3[Dd].*)$
    windowrulev2 = opaque, class:^(.*[Ss]weet[Hh]ome3[Dd].*)$
  '';
}
