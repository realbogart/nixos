{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-realbogart.url = "github:realbogart/nixpkgs";
    # nixpkgs.url = "github:realbogart/nixpkgs/24.05-johan";
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld.url = "github:Mic92/nix-ld";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-yaml.url = "github:realbogart/nix-yaml";
    nix-azure-pipelines-language-server.url = "github:realbogart/nix-azure-pipelines-language-server";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      NixOS-WSL,
      nix-ld,
      nix-flatpak,
      musnix,
      nix-azure-pipelines-language-server,
      nix-yaml,
      nixpkgs-realbogart,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-realbogart = import nixpkgs-realbogart {
        inherit system;
        config.allowUnfree = true;
      };
      johan-home =
        {
          configName ? "default",
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.johan = import ./home.nix {
            inherit
              configName
              nix-yaml
              nix-azure-pipelines-language-server
              pkgs-realbogart
              ;
          };
        };
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/base.nix
          ./configuration-wsl.nix
          NixOS-WSL.nixosModules.wsl
          home-manager.nixosModules.home-manager
          (johan-home { })
          nix-ld.nixosModules.nix-ld
          {
            programs.nix-ld.enable = true;
            programs.nix-ld.dev.enable = false;
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
          ./modules/base.nix
          musnix.nixosModules.musnix
          ./configuration-desktop.nix
          home-manager.nixosModules.home-manager
          nix-flatpak.nixosModules.nix-flatpak
          (johan-home { configName = "desktop"; })
          nix-ld.nixosModules.nix-ld
          {
            programs.nix-ld.enable = true;
            programs.nix-ld.dev.enable = false;
            programs.nix-ld.libraries = with pkgs; [
              stdenv.cc.cc
              libz
            ];
          }
        ];
      };
      nixosConfigurations.monstret = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/base.nix
          musnix.nixosModules.musnix
          ./configuration-monstret.nix
          home-manager.nixosModules.home-manager
          nix-flatpak.nixosModules.nix-flatpak
          (johan-home { configName = "desktop"; })
          nix-ld.nixosModules.nix-ld
          {
            programs.nix-ld.enable = true;
            programs.nix-ld.dev.enable = false;
            programs.nix-ld.libraries = with pkgs; [
              stdenv.cc.cc
              libz
            ];
          }
        ];
      };
    };
}
