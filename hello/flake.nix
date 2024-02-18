{
  description = "virtual environments";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = {
    flake-utils,
    devshell,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlays.default
            (prev: next: {
              hello = hello';
            })
          ];
        };

        hello' = pkgs.stdenvNoCC.mkDerivation {
          name = "hello";
          src = ./bin;
          buildPhase = ''
            mkdir -p $out/bin
            cp ./hello $out/bin
          '';
        };
      in {
        devShells.default = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };

        packages.default = hello';

        formatter = pkgs.alejandra;
      }
    );
}
