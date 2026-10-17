# Shared system configuration applied to every host.
# Each concern lives in its own module; this file just wires them together.
{ ... }:

{
  imports = [
    ./nix.nix
    ./nh.nix
    ./locale.nix
    ./networking.nix
    ./desktop.nix
    ./audio.nix
    ./virtualisation.nix
    ./bluetooth.nix
    ./gaming.nix
    ./printing.nix
    ./users.nix
    ./fonts.nix
    ./packages.nix
    ./goxlr.nix
  ];
}
