{
  description = "code-server - VS Code in the browser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }: flake-utils.lib.eachSystem
    [ "x86_64-linux" "aarch64-linux" "armv7l-linux" "x86_64-darwin" "aarch64-darwin" ]
    (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      # To update: change version, then set all hashes to "" and build.
      # The error messages will contain the correct hashes.
      # Release tags: https://github.com/coder/code-server/releases
      version = "4.111.0";

      platformInfo = {
        "x86_64-linux"   = { os = "linux"; arch = "amd64";  hash = "sha256-OPw+d3kdacQP5AD7m2gbto0yCn/vi09Re/6WtTzv8K0="; };
        "aarch64-linux"  = { os = "linux"; arch = "arm64";  hash = "sha256-BctYlG5qMIsSXTQOhzg2kgcnyS9jAGgVo45zWkQYz08="; };
        "armv7l-linux"   = { os = "linux"; arch = "armv7l"; hash = "sha256-dRCuHdypVDHQmjcirP0lOyn3M9LpIla2T7ufrOy2sl0="; };
        "x86_64-darwin"  = { os = "macos"; arch = "amd64";  hash = "sha256-B/pQwLvzs16Ybka7oA+O97mhvahC0GL/3n7Vx+Veu8s="; };
        "aarch64-darwin" = { os = "macos"; arch = "arm64";  hash = "sha256-EEclCKZHCQSk9cySEjjqQVcC3e4ogGHMonK3odhVcFA="; };
      };

      info = platformInfo.${system};

      src = pkgs.fetchurl {
        url = "https://github.com/coder/code-server/releases/download/v${version}/code-server-${version}-${info.os}-${info.arch}.tar.gz";
        inherit (info) hash;
      };
    in
    {
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "code-server";
        inherit version src;

        sourceRoot = "code-server-${version}-${info.os}-${info.arch}";

        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp -r . $out/

          # Wrap the binary to find node and set up the environment
          wrapProgram $out/bin/code-server \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs ]}

          runHook postInstall
        '';

        dontFixup = true;

        meta = {
          description = "VS Code in the browser";
          homepage = "https://github.com/coder/code-server";
          mainProgram = "code-server";
          platforms = builtins.attrNames platformInfo;
        };
      };
    });
}
