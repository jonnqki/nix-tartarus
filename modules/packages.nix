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
      ripgrep
      tree
      tealdeer
      htop
      unzip
      git
      fastfetch
      cmatrix
      pokeget-rs
      cowsay
      nmap
      pciutils
      wl-clipboard
      playerctl
      sbctl
      ddcutil
      yt-dlp
      ffmpeg

      # Development
      gcc
      python3
      tree-sitter
      neovim
      vim
      claude-code

      # Wayland desktop shell & utilities
      xwayland-satellite
      swaybg
      fuzzel
      hyprlock
      hyprpicker
      waypaper
      awww
      quickshell
      orca
      dconf
      glib
      ghostty

      # Applications
      google-chrome
      brave
      telegram-desktop
      vesktop
      spotify
      mpv
      qbittorrent
      obs-cmd
      ani-cli
      pavucontrol
      davinci-resolve
      cava
    ])
    ++ [
      # Flake inputs
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
