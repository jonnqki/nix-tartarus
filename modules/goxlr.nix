# GoXLR support, gated behind `my.goxlr.enable`.
# Only hosts that flip this on (Tartarus) pull in the utility + daemon.
{ config, lib, ... }:

let
  cfg = config.my.goxlr;
in
{
  options.my.goxlr.enable = lib.mkEnableOption "GoXLR utility and audio routing";

  config = lib.mkIf cfg.enable {
    # Installs the goxlr-utility package and sets up the daemon + udev rules.
    services.goxlr-utility.enable = true;
  };
}
