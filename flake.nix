{
  description = "sysconf — NixOS system configuration";

  # --- INPUTS
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # --- OUTPUTS
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nh,
      zen-browser,
      stylix,
      noctalia,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      mkHost =
        {
          hostname,
          username,
          modules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username; };

          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.permittedInsecurePackages = [
                "electron-39.8.10"
                "pnpm-10.29.2"
              ];
            }

            ./hosts/${hostname}/configuration.nix
            ./core.nix

            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs username; };
              home-manager.users.${username} = import ./dotfiles/home.nix;
              home-manager.backupFileExtension = "hm-backup";
            }
          ]
          ++ (map (m: ./modules/${m}.nix) modules);
        };
    in
    {
      nixosConfigurations = {

        whale = mkHost {
          hostname = "whale";
          username = "nick";
          modules = [
          ];
        };
      };
    };
}
