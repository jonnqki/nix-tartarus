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
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.spicetify"
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
      sshdocker = "ssh jonathan@192.168.1.66";
      ezals = "eza -l --icons --git  --tree";
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

  #cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ]; # cd becomes zoxide
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
      init.default.Branch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

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

  # ================================================ (B) ============================================
  # Hand-written configs
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
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
