# Adding a new machine (e.g. Mementos, the laptop)

How this repo decides which machine is which, and the steps to add a new one.

## How it works

Every machine is built from the shared parts **plus its own host folder**:

```
Tartarus = modules/ + home/jonathan.nix + hosts/tartarus/  (+ home/tartarus.nix)
Mementos = modules/ + home/jonathan.nix + hosts/mementos/  (+ home/mementos.nix)
```

| Where something lives | Which machines get it |
|---|---|
| `modules/` (imported by `modules/default.nix`) | Every machine |
| `home/jonathan.nix` | Every machine |
| `hosts/<name>/` | Only that machine |
| `home/<name>.nix` | Only the machine whose host file imports it |

Optional features use on/off switches, set per host:

- `my.gaming.enable = true;` turns on Steam, launchers and Wine
- `my.goxlr.enable = true;` turns on the GoXLR utility
- `my.secureboot.enable = true;` turns on Secure Boot with Lanzaboote (only once keys are enrolled)

### How `rebuild` picks the machine

`rebuild` (`nh os switch`) needs two things:

1. **Where the config is.** It reads the `NH_FLAKE` variable, which `modules/nh.nix` sets to `~/nixos-config`.
2. **Which machine this is.** It reads `/etc/hostname`.

It then builds the entry in `flake.nix` that has the same name.

`/etc/hostname` is generated from `networking.hostName` in `hosts/<name>/default.nix`, so the name in the host file and the name in `flake.nix` **must match exactly**, including capital letters. Don't edit `/etc/hostname` or anything in `/etc/nixos` by hand. NixOS doesn't use `/etc/nixos` with this flake.

A fresh install is called `nixos`, so the **first** build has to name the machine explicitly (`#Mementos`). After that, plain `rebuild` works.

## Steps

### 1. Install NixOS

- Use the normal installer.
- Use the username `jonathan`, so the home config fits.
- Leave Secure Boot **off** in the BIOS for now. Once everything works, create and enroll keys (`sudo sbctl create-keys`, then put the BIOS in Setup Mode and run `sudo sbctl enroll-keys --microsoft`), set `my.secureboot.enable = true;` in the host file, rebuild, and then turn Secure Boot on.

### 2. Clone the repo

The fresh install has no git, so borrow it temporarily:

```sh
nix-shell -p git gh
```

If the repo is private, log in first:

```sh
gh auth login
gh repo clone jonnqki/nix-tartarus ~/nixos-config
```

If it's public:

```sh
git clone https://github.com/jonnqki/nix-tartarus ~/nixos-config
```

Then:

```sh
cd ~/nixos-config
```

### 3. Add the machine's files

**Hardware file.** The installer generates it for this exact machine:

```sh
mkdir -p hosts/mementos
cp /etc/nixos/hardware-configuration.nix hosts/mementos/
```

**`hosts/mementos/default.nix`:**

```nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "Mementos";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Laptop power management
  services.power-profiles-daemon.enable = true;

  # Optional features (see the switches above)
  # my.gaming.enable = true;

  # NVIDIA: see "GTX 960 notes" below. Do NOT copy Tartarus's NVIDIA block.

  # Home Manager bits only for this machine
  home-manager.users.jonathan.imports = [ ../../home/mementos.nix ];

  # Copy this value from /etc/nixos/configuration.nix on the new machine.
  # Never change it afterwards.
  system.stateVersion = "XX.XX";
}
```

**`home/mementos.nix`:**

```nix
# Home Manager bits that only make sense on Mementos (laptop).
{ ... }:

{
  # Screen layout. config.kdl includes "outputs.kdl"; each machine supplies its own.
  xdg.configFile."niri/outputs.kdl".source = ./dotfiles/niri/outputs-mementos.kdl;
}
```

**`home/dotfiles/niri/outputs-mementos.kdl`.** The laptop panel is usually `eDP-1`. Check with `niri msg outputs` once niri is running, and adjust:

```kdl
output "eDP-1" {
    scale 1
}
```

**`flake.nix`.** Add one line:

```nix
nixosConfigurations = {
  "Tartarus" = mkHost ./hosts/tartarus;
  "Mementos" = mkHost ./hosts/mementos;
};
```

### 4. First build

Flakes ignore files git doesn't know about, so use `git add -A`, not `-u`:

```sh
git add -A
sudo nixos-rebuild switch --flake ~/nixos-config#Mementos --option experimental-features 'nix-command flakes'
```

- `#Mementos` builds that entry, because the machine is still called `nixos`.
- `--option ...` turns on flakes for this one command. The config enables them permanently after this.

Then reboot. From now on, `rebuild` and `update` work normally.

### 5. Share it back

On the new machine:

```sh
git commit -m "add Mementos (laptop)"
git push
```

On Tartarus:

```sh
git pull
```

## GTX 960 notes (Mementos)

- The GTX 960 is a **Maxwell** card. It needs `hardware.nvidia.open = false;`. The open kernel module only supports GTX 16xx / RTX 20xx and newer.
- The current driver no longer supports Maxwell. Use the **legacy 580** driver branch instead of `nvidiaPackages.stable`, and check the exact attribute name in nixpkgs at the time.
- If the laptop also has Intel graphics (likely with a 960M), set up **PRIME offload** (`hardware.nvidia.prime`). Intel runs the desktop and NVIDIA is used on demand.
- For heavy games, stream them from Tartarus: Steam Remote Play, or Sunshine on Tartarus with Moonlight on the laptop.
