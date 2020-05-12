{ pkgs ? import <nixpkgs> { } }:

let
  yarn2nix = pkgs.yarn2nix-moretea;

  easy-ps = import ./nix/easyPurescript.nix { inherit pkgs; };
  vscode = import ./nix/vscode.nix { inherit pkgs; };
  nodeJsShell = import ./nix/nodeModulesShell.nix { inherit yarn2nix; };

  inherit (nodeJsShell) mkNodeModulesShell;

  codit = import ./default.nix { };

in mkNodeModulesShell codit {
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  buildInputs = with easy-ps; [ purs spago spago2nix purty vscode ];
}
