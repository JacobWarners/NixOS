{ config, pkgs, ... }:

{
  # This is the ONLY block you need for your graphics drivers.
  # It correctly enables the standard Mesa/RADV drivers for BOTH your Intel and AMD GPUs,
  # including the 32-bit support that Steam absolutely requires.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # This is for GPU performance tuning. It is safe to keep.
  hardware.amdgpu.overdrive.enable = true;
  hardware.amdgpu.overdrive.ppfeaturemask = "0xffffffff";

  # Enable gamemode for better performance in games.
  programs.gamemode.enable = true;
}
