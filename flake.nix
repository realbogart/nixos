{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:realbogart/nixpkgs/24.05-johan";
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld.url = "github:Mic92/nix-ld";
    nix-yaml.url = "github:realbogart/nix-yaml";
  };

  outputs =
    { self, nixpkgs, home-manager, NixOS-WSL, nix-ld, nix-yaml, ... }@inputs:
    let
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs { inherit system; };
      johan-home = { configName ? "default" }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.johan =
          import ./home.nix { inherit configName nix-yaml; };
      };
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration-wsl.nix
          NixOS-WSL.nixosModules.wsl
          home-manager.nixosModules.home-manager
          (johan-home { })
          nix-ld.nixosModules.nix-ld
          {
            programs.nix-ld.dev.enable = true;
            programs.nix-ld.libraries = with pkgs; [
              stdenv.cc.cc
              libz
              ncurses6
            ];
          }
        ];
      };
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration-desktop.nix
          home-manager.nixosModules.home-manager
          (johan-home { configName = "desktop"; })
          nix-ld.nixosModules.nix-ld
          {
            # programs.nix-ld.enable = true;
            programs.nix-ld.dev.enable = true;
            programs.nix-ld.dev.libraries = with pkgs; [ stdenv.cc.cc libz ];
          }
        ];
      };
      nixosConfigurations.worklaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration-worklaptop.nix
          home-manager.nixosModules.home-manager
          (johan-home { configName = "worklaptop"; })
          nix-ld.nixosModules.nix-ld
          {
            programs.nix-ld.enable = true;
            programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc libz ];
          }
        ];
      };
    };
}
