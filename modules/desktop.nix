# Display stack: graphics, SDDM, Plasma 6 and the Niri session.
{ pkgs, lib, ... }:

{
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # Steam
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = lib.mkForce "niri";

  # The greeter's QML cache is keyed on /run/current-system paths and fixed Nix
  # store mtimes, so it survives Plasma upgrades and loads stale compiled themes.
  systemd.tmpfiles.rules = [ "R /var/lib/sddm/.cache - - - - -" ];

  programs.niri.enable = true;

  # Desktop integration
  programs.dconf.enable = true;
  services.gvfs.enable = true; # Nautilus trash, mounts, network shares
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
