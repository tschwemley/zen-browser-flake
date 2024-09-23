{
  description = "Zen Browser";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    version = "1.0.1-a.3";

    downloadUrl = {
      "specific" = {
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-specific.tar.bz2";
        sha256 = "sha256-tdXdS73iMwG0NWseDGxmqj+iuZ2YkpZvsQPNgKmvDdc=";
      };
      "generic" = {
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-generic.tar.bz2";
        sha256 = "";
      };
    };

    pkgs = nixpkgs.legacyPackages.${system};

    mkZen = sourceInfo: pkgs.callPackage ./package.nix {inherit sourceInfo;};
  in {
    packages."${system}" = {
      generic = mkZen {
        variant = "generic";
        src = downloadUrl.generic;
        inherit version;
      };
      specific = mkZen {
        variant = "specific";
        src = downloadUrl.specific;
        inherit version;
      };
      default = self.packages.${system}.specific;
    };
  };
}
