# Gaming: Steam (+ gamescope) and the various launchers.
# Gated behind 'my.gaming.enable'
{
  config,
  pkgs,
  lib,
  ...
}:

let
  # TEMPORARY, remove after `nix flake update` picks up nixpkgs with
  # millennium >= 3.6.3 (then switch back to pkgs.steamWithMillennium).
  # Steam's client moved to the 64-bit steamrt64 layout in Nov 2026;
  # millennium 3.6.2 (current channel) only injects into the old
  # ubuntu12_32/64 paths, so it silently never loads. 3.6.3 + the
  # steamrt64 symlink below are the fix, vendored from nixpkgs master.
  millennium = pkgs.callPackage ../pkgs/millennium.nix { };
  steamWithMillennium' =
    (pkgs.steam.override (prevArgs: {
      extraLibraries = p: (prevArgs.extraLibraries or (_: [ ])) p ++ [ millennium ];
      extraProfile = (prevArgs.extraProfile or "") + ''
        mkdir -p "$HOME/.local/share/Steam/steamrt64"
        ln -sf ${millennium}/lib/libmillennium_bootstrap_x64.so "$HOME/.local/share/Steam/steamrt64/libXtst.so.6"
      '';
    })).overrideAttrs
      (old: {
        pname = "steam-with-millennium";
      });
in
{
  options.my.gaming.enable = lib.mkEnableOption "Steam, launcher and gaming tools";

  config = lib.mkIf config.my.gaming.enable {

    # programs.steam installs Steam in its FHS env and (with these flags) opens
    # the Remote Play / friends / dedicated-server firewall ports.
    programs.steam = {
      enable = true;
      # Steam with the Millennium client mod baked in — needed for skins
      # (Material-Theme + Noctalia's steam template colors it via Matugen)
      package = steamWithMillennium';
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
      # nixpkgs' cargo hook forces AWS_LC_SYS_USE_SYSTEM=1, but the package
      # doesn't provide aws-lc. Drop this override once nixpkgs adds it.
      (deadlock-mod-manager.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ aws-lc ];
      }))
    ];
  };
}
