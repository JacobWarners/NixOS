{ config, lib, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true; # Enable 32-bit support for Steam and Wine
    
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
  
  # Optionally, prefer AMDVLK over RADV for better performance in some cases
  environment.variables = {
    AMD_VULKAN_ICD = "AMDVLK";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json:/run/opengl-driver-32/share/vulkan/icd.d/amd_icd32.json";
  };
  
  # Add kernel parameters for better performance
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff" # Enables power management features
    "radeon.si_support=0"
    "radeon.cik_support=0"
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];
}
