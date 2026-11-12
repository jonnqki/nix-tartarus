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

  # Ghostty cursor-trail shaders (MIT). The trail takes the cursor colour, so it
  # follows the Noctalia palette.
  ghostty-cursor-shaders = pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "9ad9158a93c0de0c045e1c6b27df37da698bc8af";
    hash = "sha256-TnoQvptwjs6P5/JfJO1CR3yhCfCcaw5wvPr5oEhn4Ho=";
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
    fd
    yazi
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
    jq # needed by Noctalia template hooks (fastfetch)

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
    keepassxc
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
      # Cursor glides to its new position instead of jumping (Neovide-style).
      # Other effects in that repo: cursor_sweep, cursor_tail, ripple_cursor, sonic_boom_cursor.
      "custom-shader" = "${ghostty-cursor-shaders}/ghostty/cursor_warp.glsl";
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
      theme = ""; # prompt comes from starship (themed by Noctalia)
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
      add_newline() { print ""; print ""; print "" }
      precmd_functions+=(add_newline)
      # Noctalia-generated fzf colours (rewritten whenever the palette changes)
      [ -f "$HOME/.config/fzf/themes/noctalia.sh" ] && source "$HOME/.config/fzf/themes/noctalia.sh"
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
    plugins = with pkgs.vimPlugins; [
      vim-nix
      fzf-lua
    ];

    extraConfig = ''
      set expandtab shiftwidth=2 tabstop=2 smartindent
    '';

    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>")
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>")
    '';
  };

  # Prompt. No `settings` here on purpose: HM would make starship.toml read-only,
  # and Noctalia's starship template needs to write its palette into it.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "noctalia"; # generated by Noctalia into ~/.config/bat/themes
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "noctalia"; # generated by Noctalia into ~/.config/btop/themes
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

  # Plasma left breeze_cursors in GTK's settings.ini and in dconf, so GTK/libadwaita
  # apps ignored the theme above. HM now owns settings.ini (cursor comes from
  # pointerCursor.gtk); icon theme and font are carried over from Plasma's file.
  # Noctalia only writes the gtk.css files, so this doesn't clash with it.
  gtk = {
    enable = true;
    iconTheme.name = "breeze";
    font = {
      name = "Noto Sans";
      size = 10;
    };
  };
  # GTK4 / libadwaita and the settings portal (used by Flatpaks) read this.
  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = "miku-cursor";
    cursor-size = 24;
  };
  # Flatpaks can't see ~/.icons or the /nix/store paths it links to.
  xdg.dataFile."flatpak/overrides/global".text = ''
    [Context]
    filesystems=~/.icons:ro;~/.local/share/icons:ro;/nix/store:ro;

    [Environment]
    XCURSOR_PATH=${config.home.homeDirectory}/.icons:${config.home.homeDirectory}/.local/share/icons
    XCURSOR_THEME=miku-cursor
    XCURSOR_SIZE=24
  '';

  xdg.configFile = {
    "niri/config.kdl".source = ./dotfiles/niri/config.kdl;
    "waypaper/config.ini".source = ./dotfiles/waypaper/config.ini;
    # Noctalia writes ~/.config/cava/themes/noctalia; this just selects it.
    "cava/config".text = ''
      [color]
      theme = "noctalia"
    '';

    # ============== (C) Noctalia's starship template writes its palette into this file =========
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${repoDots}/starship/starship.toml";

    # ============== (C) Noctalia's fastfetch template merges its colours into this file =========
    "fastfetch/config.jsonc".source =
      config.lib.file.mkOutOfStoreSymlink "${repoDots}/fastfetch/config.jsonc";

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
