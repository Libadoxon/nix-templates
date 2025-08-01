{
  description = "A collection of opinoated project templates";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    {
      templates =
        let
          lib = nixpkgs.lib;
          dirs = lib.attrNames (
            lib.filterAttrs (name: value: value == "directory") (builtins.readDir ./templates)
          );
          gen =
            l:
            lib.genAttrs l (
              n:
              {
                path = ./templates/${n};
              }
              // (lib.optionalAttrs (lib.pathExists ./init-scripts/${n}) {
                welcomeText = "Execute 'bash -c \"$(curl -sL https://raw.githubusercontent.com/Libadoxon/nix-templates/main/init-scripts/${n})\"' to execute setup commands";
              })
            );
        in
        gen dirs;
    };
}
