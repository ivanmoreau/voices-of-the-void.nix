{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Flake for WineCX macOS
    winecx.url = "github:ivanmoreau/winecx.macos.nix";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, winecx, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Only Darwin x86_64/aaarch64 and Linux x86_64 are supported, as wine is not available on non x86_64 platforms.
      # But we can use Rosetta 2 on Apple Silicon to run the x86_64 version.
      systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" ];
      perSystem = { self', pkgs, lib, config, system, ... }: {
        # Voices of the void game
        packages.voicesofthevoid = pkgs.stdenv.mkDerivation (this: 
          let 
            winePkg = if pkgs.stdenv.isDarwin then winecx.packages.${system}.default else pkgs.winePackages.staging;
          in {
            name = "voicesofthevoid";
            version = "0.5.2_3";
            depsBuildBuild = with pkgs; [ makeWrapper unzip ];

            buildInputs = [ winePkg ];
            
            # We assume that the user has already downloaded the game from Itch.io into the /tmp location
            # and with the default filename.
            #src = "${builtins.getEnv "HOME"}/Downloads/d052_0011.zip";
            src = "/tmp/d052_0011.zip";

            sourceRoot = "./d052_0011";

            installPhase = ''
              mkdir -p $out/bin
              mv WindowsNoEditor/ $out/WindowsNoEditor
              makeWrapper ${winePkg}/bin/wine64 $out/bin/voicesofthevoid \
                --add-flags "$out/WindowsNoEditor/VotV.exe"
            '';
          });

          packages.default = self'.packages.voicesofthevoid;

        devShells.default = pkgs.mkShell {
            buildInputs = [ 
              self'.packages.default
            ];
          };
      };
    };
}
