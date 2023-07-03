{
  description = "shell for my terraform things";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bashInteractive
            pkgs.terraform
            pkgs.kubectl
            pkgs.kubernetes-helm
            pkgs.linode-cli
            pkgs.just
            pkgs.postgresql
            pkgs.tfk8s
            pkgs.minio-client
          ];
          buildInputs = [ ];
        };
      });
}
