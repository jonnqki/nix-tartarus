# User accounts and login shell.
{ pkgs, ... }:

{
  # Enabled at system level so it's a valid login shell.
  # Per-user zsh config (oh-my-zsh, aliases, init) lives in home/jonathan.nix.
  programs.zsh.enable = true;

  users.users."jonathan" = {
    isNormalUser = true;
    description = "Jonathan";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
