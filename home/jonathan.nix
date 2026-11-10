#   (A) Native HM module
#   (B) Verbatim, read-only
#   (C) Verbatim, WRITABLE

{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

let
  # Absolute path to this repo's dotfiles on the live machine, for pattern (C).
  repoDots = "${config.home.homeDirectory}/nixos-config/home/dotfiles";

  # Animated Hatsune Miku Xcursor theme (port of petit devil's Windows set).
  miku-cursor = pkgs.stdenvNoCC.mkDerivation {
    pname = "miku-cursor";
    version = "0-unstable-319e9ff";
    src = pkgs.fetchFromGitHub {
      owner = "supermariofps";
      repo = "hatsune-miku-windows-linux-cursors";
      rev = "319e9ffbe38a6c8f31c7d6ad65c5c9a8337eba7c";
      hash = "sha256-1Rq15Up90Vnn0c7ScgbmRZsc8k70J9pTW+Rtm0xBvGM=";
    };
    installPhase = ''
      mkdir -p $out/share/icons
      cp -r miku-cursor-linux $out/share/icons/miku-cursor
    '';
  };
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
  ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.spicetify"
  ];

  home.packages = with pkgs; [

    #CLI based & system tools
    ripgrep
    cava
    tree
    tealdeer
    unzip
    fastfetch
    cmatrix
    cowsay
    nmap
    hyprpicker
    wl-clipboard
    playerctl
    yt-dlp
    ffmpeg

    # Development
    gcc
    python3
    tree-sitter
    claude-code
    ncdu

    # Wayland desktop shell & utilities
    xwayland-satellite
    swaybg
    fuzzel
    waypaper
    awww
    quickshell
    orca
    dconf
    glib
    ghostty
    nautilus

    # Applications
    telegram-desktop
    vesktop
    qbittorrent
    ani-cli
    pavucontrol
  ];

  # ======================================================== (A) ==================================================

  programs.ghostty = {
    enable = true;
    package = null;
    systemd.enable = false;
    settings = {
      "font-family" = "JetBrainsMono NF Bold";
      theme = "noctalia";
      "cursor-style" = "block";
      "cursor-style-blink" = false;
      # Ghostty's shell integration forces a bar cursor at the prompt, which
      # overrides cursor-style. "no-cursor" disables just that piece.
      "shell-integration-features" = "no-cursor";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
    };
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "sudo"
        "history"
      ];
    };
    shellAliases = {
      clipsls = "ls -la /mnt/backup/clips /mnt/backup/clips/converted";
      list = "ls -al";
      rebuild = "nh os switch";
      update = "nh os switch --update";
    };
    initContent = ''
      export DEFAULT_USER="jonathan"
      add_newline() { print ""; print ""; print "" }
      precmd_functions+=(add_newline)
      [ -t 1 ] && ${lib.getExe pkgs.fastfetch}
    '';
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [ "--group-directories-first" ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      docker = {
        HostName = "192.168.1.66";
        User = "jonathan";
      };
    };
  };

  #cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ]; # cd becomes zoxide
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true; # This hides the export list
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Jonathan";
      user.email = "itsactuallyjustjonn@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.gh.enable = true; # GitHub CLI

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.comfy;
      colorScheme = "Comfy";
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        shuffle
        {
          src = ./dotfiles/spicetify;
          name = "lyrics-translate.js";
        }
      ];
    };

  programs.neovim = {
    enable = true;
    plugins = [ pkgs.vimPlugins.vim-nix ];
    extraConfig = ''
      set expandtab shiftwidth=2 tabstop=2 smartindent
    '';
  };

  programs.bat.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY"; # uses your terminal colours,
      theme_background = false; # transparent
      update_ms = 1000;
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe"; # uses Nvidia gpu for decoding
      save-position-on-quit = true; # resumes where you leave off
      volume-max = 150;
    };
  };

  services.playerctld.enable = true;

  # ================================================ (B) ============================================
  # Hand-written configs
  home.pointerCursor = {
    enable = true;
    name = "miku-cursor";
    package = miku-cursor;
    size = 24;
    gtk.enable = true; # GTK
    x11.enable = true; # Xwayland
  };

  xdg.configFile = {
    "niri/config.kdl".source = ./dotfiles/niri/config.kdl;
    "fastfetch/config.jsonc".source = ./dotfiles/fastfetch/config.jsonc;
    "waypaper/config.ini".source = ./dotfiles/waypaper/config.ini;

    # ============== (C) (Vesktop needs to be writable because of changes manually) =================
    # Vesktop rewrites these when you change settings in-app
    "vesktop/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoDots}/vesktop/settings.json";
    "vesktop/state.json".source = config.lib.file.mkOutOfStoreSymlink "${repoDots}/vesktop/state.json";
    "vesktop/settings/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoDots}/vesktop/settings/settings.json";
    "vesktop/settings/native-settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoDots}/vesktop/settings/native-settings.json";
  };

  # ============================================== (C) =============================================
  # Noctalia hot-writes settings.toml from its UI, so it must stay writable.
  # Lives under ~/.local/state, hence home.file rather than xdg.configFile.
  home.file.".local/state/noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDots}/noctalia/settings.toml";

}
