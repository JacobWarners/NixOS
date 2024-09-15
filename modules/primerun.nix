{ config, pkgs, ... }:

let
  prime-run = pkgs.writeShellScriptBin "prime-run" ''
    #!/usr/bin/env bash
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  environment.systemPackages = with pkgs; [
    prime-run
    # ... other packages
  ];
}

