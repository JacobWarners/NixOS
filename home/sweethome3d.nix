{ config, pkgs, ... }:

# Sweet Home 3D + Hyprland smoothness fixes.
# Java Swing/JOGL on a tiling Wayland WM needs reparenting disabled and the
# XRender 2D pipeline to render cleanly. We keep the upstream package (so its
# .desktop + icon show up in rofi/launchers) and only re-wrap the binary to
# inject the right env. The desktop file's `Exec=sweethome3d` resolves via PATH
# to this wrapped binary.

let
  sweethome3d-fast = pkgs.symlinkJoin {
    name = "sweethome3d-fast";
    paths = [ pkgs.sweethome3d.application ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/sweethome3d
      makeWrapper ${pkgs.sweethome3d.application}/bin/sweethome3d $out/bin/sweethome3d \
        --set _JAVA_AWT_WM_NONREPARENTING 1 \
        --set JAVA_TOOL_OPTIONS "-Dsun.java2d.xrender=true -Dsun.java2d.uiScale=1"
    '';
  };
in
{
  home.packages = [ sweethome3d-fast ];

  # Stop Hyprland re-compositing the XWayland window every frame.
  # Class confirmed via `hyprctl clients | grep -i class`; adjust regex if needed.
  wayland.windowManager.hyprland.extraConfig = ''
    # --- Sweet Home 3D ---
    windowrule = noblur, class:^(.*[Ss]weet[Hh]ome3[Dd].*)$
    windowrule = noanim, class:^(.*[Ss]weet[Hh]ome3[Dd].*)$
    windowrule = opaque, class:^(.*[Ss]weet[Hh]ome3[Dd].*)$
  '';
}
