{ config, lib, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    
    extraPackages = with pkgs; [
      amdvlk
      intel-media-driver
      libva-utils
    ];
    
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];

#    extraPackages32 = with pkgsi686Linux; [
#        intel-media-driver
#        intel-vaapi-driver
#      ];
  };
  
  # Optionally, prefer AMDVLK over RADV for better performance in some cases
#  environment.variables = {
#    AMD_VULKAN_ICD = "AMDVLK";
#    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json:/run/opengl-driver-32/share/vulkan/icd.d/amd_icd32.json";
#  };
  
  # Add kernel parameters for better performance
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff" # Enables power management features
    "radeon.si_support=0"
    "radeon.cik_support=0"
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];
}
