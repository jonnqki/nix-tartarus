#Home manager bits that only are gor Tartarus
#Loaded from hosts/tartarus/default.nix, on top of home/jonathan.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    davinci-resolve
    obs-cmd
  ];

  # Monitor layout for this desk (DP-1 + HDMI-A-1).
  # Config.kdl includes "outputs.kl"; each machine supplies its own
  xdg.configFile."niri/outputs.kdl".source = ./dotfiles/niri/outputs-tartarus.kdl;
}
