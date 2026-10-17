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
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQ6jpvqCEmQyMHr3/WMsceVV1g0k5iOQgpKb4/W4RlC jonathan@192.168.1.71"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
