# Bluetooth.
{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
