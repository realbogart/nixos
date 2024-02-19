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
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [ 
            ./configuration.nix
	    NixOS-WSL.nixosModules.wsl
            inputs.home-manager.nixosModules.default
	
	    # make home-manager as a module of nixos
		# so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
		home-manager.nixosModules.home-manager
		{
		  home-manager.useGlobalPkgs = true;
		  home-manager.useUserPackages = true;
		  home-manager.users.johan = import ./home.nix;

		  # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
		}
          ];
        };
    };
}
