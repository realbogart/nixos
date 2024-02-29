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

    nix-ld.url = "github:Mic92/nix-ld";
  };

  outputs = { self, nixpkgs, home-manager, NixOS-WSL, nix-ld, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      johan-home = { configName ? "default" }: {
	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;
	home-manager.users.johan = import ./home.nix configName;
      };
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./configuration.nix
	    NixOS-WSL.nixosModules.wsl
	    home-manager.nixosModules.home-manager (johan-home {})
            nix-ld.nixosModules.nix-ld
            { 
              programs.nix-ld.enable = true; 
              programs.nix-ld.libraries = with pkgs; [
                stdenv.cc.cc
                zlib
                openssl
                libz
              ];
            }
          ];
        };
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./configuration-desktop.nix
	    home-manager.nixosModules.home-manager (johan-home { configName = "desktop"; })
          ];
        };
    };
}
