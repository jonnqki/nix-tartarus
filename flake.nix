{
  description = "NixOS configuration (multi-host)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # no nixpkgs.follows on purpose: keeps the noctalia binary cache usable
    noctalia.url = "github:noctalia-dev/noctalia";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      spicetify-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Pre-commit hooks: run statix (lint) and nixfmt (format) before each commit.
      pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          statix = {
            enable = true;
            settings.config = ".statix.toml";
          };
          nixfmt.enable = true;
        };
      };

      # Shared modules every host gets.
      baseModules = [
        ./modules
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-bak";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.jonathan = import ./home/jonathan.nix;
        }
      ];

      mkHost =
        hostModule:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = baseModules ++ [ hostModule ];
        };
    in
    {
      nixosConfigurations = {
        "Tartarus" = mkHost ./hosts/tartarus;
        #Add more hosts for more machines, (up coming laptop)
      };

      # `nix flake check` runs the hooks against the whole tree.
      checks.${system}.pre-commit = pre-commit-check;

      # `nix develop` installs the git pre-commit hook (via shellHook) and drops
      # you into a shell with statix + nixfmt on PATH.
      devShells.${system}.default = pkgs.mkShell {
        inherit (pre-commit-check) shellHook;
        buildInputs = pre-commit-check.enabledPackages;
      };
    };
}
