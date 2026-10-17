# Display stack: graphics, SDDM, Plasma 6 and the Niri session.
{ pkgs, lib, ... }:

{
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # Steam

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = lib.mkForce "niri";

  programs.niri.enable = true;

  # Desktop integration
  programs.dconf.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
