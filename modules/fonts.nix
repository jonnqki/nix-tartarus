# System fonts.
{ pkgs, ... }:

{
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.meslo-lg
      corefonts
      vista-fonts
    ];
  };
}
