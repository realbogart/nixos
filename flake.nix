{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, NixOS-WSL, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      johan-home = {
	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;
	home-manager.users.johan = import ./home.nix;
      };
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./configuration.nix
	    NixOS-WSL.nixosModules.wsl
	    home-manager.nixosModules.home-manager johan-home
          ];
        };
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./configuration-desktop.nix
	    home-manager.nixosModules.home-manager johan-home
          ];
        };
    };
}
