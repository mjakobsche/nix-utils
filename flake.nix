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
          # Function requires a derivation along with it's meta data instead
          # of a built store path provided by `nix bundle`
          derivation = program: parseDrvName (elemAt (split "/" (elemAt (split "/[0-9a-df-np-sv-z]{32}-" (program)) 2)) 0);
          version = derivation: if derivation.version != "" then derivation.version else "1.0";
          package = program: derivation: system: let
            name = derivation.name;
            in (pkgs system).runCommand name {} ''
             mkdir -p $out/bin
             ln -s ${program} $out/bin/.
          '';
          defaultVersion = "1.0";
          utils = system: (pkgs system).callPackage ./utils/rpm-deb {};
             in
    {
      rpm = { program, system }: {
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
          # Function requires a derivation along with it's meta data instead
          # of a built store path provided by `nix bundle`
          derivation = program: parseDrvName (elemAt (split "/" (elemAt (split "/[0-9a-df-np-sv-z]{32}-" (program)) 2)) 0);
          version = derivation: if derivation.version != "" then derivation.version else "1.0";
          package = program: derivation: system: let
            name = derivation.name;
            in (pkgs system).runCommand name {} ''
             mkdir -p $out/bin
             ln -s ${program} $out/bin/.
          '';
          defaultVersion = "1.0";
          utils = system: (pkgs system).callPackage ./utils/rpm-deb {};
             in
    {
      rpm = { program, system }: {
          drv = derivation program;
          (utils system).buildFakeSingleRPM (package drv system) (version drv);
      };

      deb = { program, system }: {
          drv = derivation program;
          (utils system).buildFakeSingleDeb (package drv system) (version drv);
      };
    };
    defaultBundler = self.bundlers.rpm;
  };
}

          (utils system).buildFakeSingleRPM (package drv system) (version drv);
      }

      deb = { program, system }: {
          drv = derivation program;
          (utils system).buildFakeSingleDEB (package drv system) (version drv);
      }
    };
    defaultBundler = self.bundlers.rpm;
  };
}
