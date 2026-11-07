# System-wide packages (host-specific ones live in the host module).
# Grouped by purpose. Gaming packages live in gaming.nix; fonts in fonts.nix;
# docker-compose in virtualisation.nix. niri/appimage-run/mullvad/steam/flatpak/
# localsend all come from their own service/program modules, not from here.
{ pkgs, inputs, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      # CLI & system tools
      wget
      git
      sbctl
      ddcutil
      gparted

      # Networking
      mullvad-vpn

    ])
    ++ [
      # Flake inputs
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
