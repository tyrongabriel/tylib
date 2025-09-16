{
  description = "A multi-system Nix library flake with modules and functions";

  inputs = {
    # Helper for Flakes
    flake-parts.url = "github:hercules-ci/flake-parts";

    # My Nixpkgs/HomeManager for the modules
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        # The systems my flake will support
        systems = [
          "x86_64-linux"
        ];
      }
      {
        # Function will evaluate for each declared system
        perSystem =
          {
            # config,
            # self',
            # inputs',
            pkgs,
            system,
            ...
          }:
          let
            myLib = import ./lib { inherit inputs; }; # Imports the lib to give access to stuff like filesIn etc.
            # `pkgs` here is the nixpkgs instance for the current `system`
            pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
            pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

            # Lib only needs regular nixpkgs
            lib = import myLib.filesIn ./lib {
              inherit (pkgs) lib; # The (pkgs) part is a scope. It tells inherit to look for the lib attribute inside the pkgs attribute set.
              inherit pkgs-stable pkgs-unstable;
            };

            # NixosModules that can be imported by other flakes
            # `flake-parts` takes care of nesting them under the correct system
            nixosModules = {
              default = {
                # Args to pass to the modules
                specialArgs = {
                  inherit lib pkgs-stable pkgs-unstable;
                };
                ## Modules to import
                imports = myLib.filesIn ./nixosModules;
              };
            };

            # Home Manager modules.
            homeManagerModules = {
              default = {
                specialArgs = {
                  inherit lib pkgs-stable pkgs-unstable;
                };
                imports = myLib.filesIn ./homeModules;
              };
            };
          in
          {
            # Expose the outputs.
            # flake-parts will automatically expose these under `nixosModules.<system>`
            # etc., without you having to manually write it.
            inherit lib nixosModules homeManagerModules;
          };
      };
}
