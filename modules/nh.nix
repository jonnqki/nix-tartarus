# nh — a nicer frontend for nixos-rebuild / nix GC.
# Usage: `nh os switch` (rebuild), `nh os boot`, `nh clean all`, `nh search <pkg>`.
{ ... }:

{
  programs.nh = {
    enable = true;

    # Lets you run `nh os switch` from anywhere without passing --flake.
    flake = "/home/jonathan/nixos-config";

    # Automatic garbage collection: keep the last 10 generations and anything
    # from the past week, prune the rest on a timer.
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 10";
    };
  };
}
