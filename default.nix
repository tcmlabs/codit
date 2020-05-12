{ pkgs ? import <nixpkgs> { } }:
let
  easy-ps = import (./nix/easyPurescript.nix) { inherit pkgs; };
  spagoPkgs = import ./spago-packages.nix { inherit pkgs; };
  nodeJsShell = import ./nix/nodeModulesShell.nix { inherit yarn2nix; };

  yarn2nix = pkgs.yarn2nix-moretea;

  inherit (pkgs) stdenv which;
  inherit (easy-ps) purs spago;

  pname = "codit";
  version = "0.0.1";
  name = pname + "-" + version;
in stdenv.mkDerivation rec {
  inherit version pname name;
  src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;

  buildInputs = [ which ] ++ [ purs spago ]
    ++ [ pkgs.yarn2nix pkgs.yarn pkgs.nodejs ];

  nodeDependencies = pkgs.yarn2nix-moretea.mkYarnModules {
    inherit name pname version;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
  };

  buildPhase = ''
    # See https://github.com/justinwoo/spago2nix/pull/15
    ${spagoPkgs.installSpagoStyle} # == spago2nix install
    ${spagoPkgs.buildSpagoStyle}   # == spago2nix build
    ${pkgs.yarn2nix-moretea.linkNodeModulesHook}
  '';

  installPhase = ''
    mkdir -p $out

    cp -r .spago $out
    cp -r output $out
    cp -r ${node_modules} $out
  '';

  node_modules = nodeDependencies
    + "/node_modules"; # used by linkNodeModulesHook in shellHook
}
