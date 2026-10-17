# Containers and alternative app-packaging formats (AppImage, Flatpak).
{ pkgs, ... }:

{
  # AppImage support (programs.appimage also provides the `appimage-run` wrapper).
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Flatpak. The service registers the systemd units and portals; the bare
  # `flatpak` package alone does not, so this is required for it to work.
  # Add Flathub once with:
  #   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;

  # Docker engine + CLI. The "docker" group is intentionally NOT granted to any
  # user (it's root-equivalent) — run docker with sudo.
  # NVIDIA container toolkit is host-specific and lives in the host module.
  virtualisation.docker.enable = true;
  environment.systemPackages = [ pkgs.docker-compose ];
}
