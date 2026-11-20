# Wooting keyboard (Two HE ARM): udev rules so the logged-in user can
# talk to it over hidraw — needed for Wootility / the web configurator.
{ pkgs, ... }:

{
  services.udev.packages = [ pkgs.wooting-udev-rules ];
}
