{ config, pkgs, ... }:

{
  # Virtual camera device for screen sharing (bypasses Zoom's broken PipeWire)
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="Screen Share" exclusive_caps=1
  '';

  environment.systemPackages = with pkgs; [
    wf-recorder
    v4l-utils
  ];
}
