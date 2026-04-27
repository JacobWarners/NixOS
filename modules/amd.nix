{ config, pkgs, ... }:

{
  # This is the ONLY block you need for your graphics drivers.
  # It correctly enables the standard Mesa/RADV drivers for BOTH your Intel and AMD GPUs,
  # including the 32-bit support that Steam absolutely requires.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable gamemode for better performance in games.
  programs.gamemode.enable = true;
}
