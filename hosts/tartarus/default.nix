# Tartarus (NVIDIA desktop).
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "Tartarus";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NVIDIA
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  # Test: AOC on DP-1 shows a shifted picture on first boot; skip nvidia's fbdev console
  boot.kernelParams = [ "nvidia_drm.fbdev=0" ];
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

  # Workaround: nixpkgs' v4l2loopback 0.15.4 ships depmod output (modules.alias etc.)
  # that collides with the kernel's own in the linux-modules buildEnv. Drop it.
  boot.kernelPackages = pkgs.linuxPackages.extend (
    _: prev: {
      v4l2loopback = prev.v4l2loopback.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm -f $out/lib/modules/*/modules.*
        '';
      });
    }
  );

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
