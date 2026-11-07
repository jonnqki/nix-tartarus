# Gaming: Steam (+ gamescope) and the various launchers.
# Gated behind 'my.gaming.enable'
{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.my.gaming.enable = lib.mkEnableOption "Steam, launcher and gaming tools";

  config = lib.mkIf config.my.gaming.enable {

    # programs.steam installs Steam in its FHS env and (with these flags) opens
    # the Remote Play / friends / dedicated-server firewall ports.
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      lutris
      heroic
      prismlauncher
      r2modman
      protonup-qt
      wine-wayland
      winetricks
      deadlock-mod-manager
    ];
  };
}
