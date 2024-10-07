{
  description = "Nix-Utils, nix utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  let
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    rpmDebUtils = pkgs.callPackage ./utils/rpm-deb {};

  })) // {
    bundlers =  with builtins; let
          pkgs = system: import nixpkgs {
            inherit system;
          };
          derivation = program: parseDrvName (elemAt (split "/" (elemAt (split "/[0-9a-df-np-sv-z]{32}-" (program)) 2)) 0);
          version = derivation: if derivation.version != "" then derivation.version else "1.0";
          # Function requires a derivation along with it's meta data instead
          # of a built store path provided by `nix bundle`
          package = program: derivation: system: let
            name = derivation.name;
            version = derivation.version;
            in (pkgs system).runCommand name {} ''
             mkdir -p $out/bin
             ln -s ${program} $out/bin/.
          '';
          defaultVersion = "1.0";
          utils = system: (pkgs system).callPackage ./utils/rpm-deb {};
             in
    {
      rpm = { program, system }: let
        drv = derivation program;
        pkg = package program drv system;
        ver = version drv;
      in (utils system).buildFakeSingleRPM pkg ver;

      deb = { program, system }: let
        drv = derivation program;
        pkg = package program drv system;
        ver = version drv;
      in builtins.trace "package: ${pkg}" (utils system).buildFakeSingleDeb pkg ver;
    };
    defaultBundler = self.bundlers.rpm;
  };
}
