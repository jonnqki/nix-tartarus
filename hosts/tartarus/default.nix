# Tartarus (NVIDIA desktop).
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "Tartarus";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # OBS with NVENC (wrapper needs the NVIDIA encode libs on LD_LIBRARY_PATH)
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    package = pkgs.symlinkJoin {
      name = "obs-studio-nvenc";
      paths = [ pkgs.obs-studio ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/obs \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
      '';
    };
  };

  # NVIDIA Container Toolkit — lets Docker containers see the GPU.
  # Host-specific because it depends on the NVIDIA driver above.
  hardware.nvidia-container-toolkit.enable = true;

  # GoXLR lives on this box only
  my.goxlr.enable = true;

  # Second drive (backup) — UUID is specific to this machine
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/ed4328c4-1a59-464a-9fcb-21105c9ca84f";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  system.stateVersion = "26.05";
}
