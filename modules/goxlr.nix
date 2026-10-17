# GoXLR support, gated behind `my.goxlr.enable`.
# Only hosts that flip this on (Tartarus) pull in the utility.
{ config, lib, pkgs, ... }:

let
  cfg = config.my.goxlr;
in {
  options.my.goxlr.enable =
    lib.mkEnableOption "GoXLR utility and audio routing";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.goxlr-utility ];
  };
}
