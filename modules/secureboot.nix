# Secure Boot via Lanzaboote. Turn on per host with `my.secureboot.enable = true;`.
# Lanzaboote replaces systemd-boot's installer and signs every boot file on each
# rebuild, using the sbctl keys in /var/lib/sbctl (already enrolled on Tartarus).
{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.my.secureboot.enable = lib.mkEnableOption "Secure Boot with Lanzaboote";

  config = lib.mkIf config.my.secureboot.enable {
    # Lanzaboote takes over from the normal systemd-boot setup
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      # /boot is only 1 GB and each NVIDIA initrd is ~130 MB: keep the last 5 generations
      configurationLimit = 5;
    };
    # sbctl itself is installed in packages.nix (check with `sudo sbctl verify`)
  };
}
