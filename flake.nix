{
  description = "NixOS configuration (multi-host)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kopuz.url = "github:temidaradev/kopuz";

    # no nixpkgs.follows on purpose: keeps the noctalia binary cache usable
    noctalia.url = "github:noctalia-dev/noctalia";
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, ... }@inputs:
  let
    # Shared modules every host gets.
    baseModules = [
      ./modules/common.nix
      ./modules/goxlr.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-bak";
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.jonathan = import ./home/jonathan.nix;
      }
    ];

    mkHost = hostModule: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = baseModules ++ [ hostModule ];
    };
  in {
    nixosConfigurations = {
      "Tartarus" = mkHost ./hosts/tartarus;
      #Add more hosts for more machines, (up coming laptop)
    };
  };
}
