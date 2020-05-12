{ yarn2nix }: rec {
  # Creates a shell with node_modules symlinked from /nix/store
  mkNodeModulesShell = drv:
    { name ? pname + "-" + version, pname ? "node-modules-shell"
    , version ? "0.0.0", packageJSON, yarnLock, buildInputs ? [ ], ... }@attr:
    let
      inherit (yarn2nix) linkNodeModulesHook mkYarnModules;

      nodeDependencies =
        mkYarnModules { inherit name pname version packageJSON yarnLock; };
    in drv.overrideAttrs (baseDerivation:
      {
        buildInputs = drv.buildInputs
          ++ buildInputs; # TODO: move this responsibility away

        shellHook = ''
          ${linkNodeModulesHook}
        '';

        node_modules = nodeDependencies
          + "/node_modules"; # used by linkNodeModulesHook in shellHook
      } // attr);
}
