# Shared system configuration applied to every host.
{ config, pkgs, inputs, ... }:

{
  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Binary caches
  nix.settings = {
    substituters = [ "https://kopuz.cachix.org" "https://noctalia.cachix.org" ];
    trusted-public-keys = [
      "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.networkmanager.enable = true;
  services.resolved.enable = true; # Steam download fix
  services.mullvad-vpn.enable = true;

  # Locale / time
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console.keyMap = "uk";

  # Display stack (Wayland + fallback X11, KDE/SDDM)
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # Steam
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.niri.enable = true;

  # Desktop integration
  programs.dconf.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Audio (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Shell — enabled at system level so it's a valid login shell.
  # Per-user zsh config (oh-my-zsh, aliases, init) lives in home/jonathan.nix.
  programs.zsh.enable = true;

  # Spicetify is configured per-user via Home Manager (see home/jonathan.nix).

  # AppImage support
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Misc programs / services
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  programs.kdeconnect.enable = true;
  programs.localsend.enable = true;
  services.printing.enable = true;
  services.flatpak.enable = true;
  fonts.fontconfig.enable = true;

  # Docker engine + CLI (user is in the "docker" group below, so no sudo needed).
  # NVIDIA container toolkit is host-specific and lives in the host module.
  virtualisation.docker.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # User
  users.users."jonathan" = {
    isNormalUser = true;
    description = "Jonathan";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQ6jpvqCEmQyMHr3/WMsceVV1g0k5iOQgpKb4/W4RlC jonathan@192.168.1.71"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # SSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    ports = [ 22 ];
  };

  # System-wide packages (host-specific ones live in the host module)
  environment.systemPackages = with pkgs; [
    wget
    cowsay
    google-chrome
    brave
    ripgrep
    yt-dlp
    docker-compose
    r2modman
    lutris
    mullvad-vpn
    nmap
    telegram-desktop
    tree
    ffmpeg
    heroic
    ddcutil
    qbittorrent
    davinci-resolve
    cava
    tealdeer
    cmatrix
    claude-code
    wine-wayland
    winetricks
    python3
    prismlauncher
    protonup-qt
    appimage-run
    wl-clipboard
    playerctl
    sbctl
    mpv
    fzf
    tree-sitter
    gcc
    deadlock-mod-manager
    pavucontrol
    xwayland-satellite
    awww
    waypaper
    pciutils
    dconf
    glib
    neovim
    vim
    fastfetch
    pokeget-rs
    flatpak
    obs-cmd
    ani-cli
    git
    nerd-fonts.meslo-lg
    htop
    spotify
    hyprpicker
    ghostty
    unzip
    swaybg
    fuzzel
    hyprlock
    orca
    niri
    quickshell
    corefonts
    vista-fonts
    vesktop
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
