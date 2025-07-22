# /etc/nixos/modules/bluetooth.nix
#
# This module enables Bluetooth services and installs related tools.

{ config, pkgs, ... }:

{
  # 1. Enable the core Bluetooth service (bluez).
  hardware.bluetooth.enable = true;

  # 2. Power on the Bluetooth adapter on boot.
  # This is useful for systems that don't enable it by default.
  hardware.bluetooth.powerOnBoot = true;

  # 3. Enable Blueman, a graphical Bluetooth manager.
  # This gives you a GUI to pair and manage devices.
  services.blueman.enable = true;

  # 4. Explicitly add necessary packages to the system environment.
  # While enabling the services often pulls these in, being explicit is good practice.
  environment.systemPackages = with pkgs; [
    bluez
    blueman
  ];
  services.tlp.settings = {
  # ... other TLP settings

  # Ensure bluetooth is not listed in devices to disable
  DEVICES_TO_DISABLE_ON_STARTUP = ""; # Or ensure "bluetooth" is not in the list

  # Or more explicitly, tell it to restore the bluetooth state
  RESTORE_DEVICE_STATE_ON_STARTUP = 1;
};
}

