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
        /*
        devshell, spin up a developer shell using `nix develop`
        */
        devShells.default = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };

        /*
        default package this flake will provide when installed via `profile install`
        */
        packages.default = hello';

        /*
        nix formatter, used when running `nix fmt`
        */
        formatter = pkgs.alejandra;
      }
    );
}
