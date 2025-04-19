{
  description = "";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    fenix.url = "github:nix-community/fenix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      flake-utils,
      naersk,
      fenix,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        toolchain =
          with fenix.packages.${system};
          combine (
            (with default; [
              rustc
              cargo
              clippy
            ])
            ++ [
              complete.rustc-codegen-cranelift-preview
              targets.wasm32-unknown-unknown.latest.rust-std
            ]
          );

        naersk' = naersk.lib.${system}.override {
          cargo = toolchain;
          rustc = toolchain;
        };
      in
      {
        packages = {
          default = naersk'.buildPackage {
            src = ./.;
          };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs =
            (with pkgs; [
              mold
              clang
            ])
            ++ [
              toolchain
            ];
        };
      }
    );
}
