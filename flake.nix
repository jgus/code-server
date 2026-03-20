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
      version = "4.112.0";

      platformInfo = {
        "x86_64-linux"   = { os = "linux"; arch = "amd64";  hash = "sha256-hqLLiQOIRsKubKGUWlbqrUc7I/FFcn+dkj9tF0tDbyw="; };
        "aarch64-linux"  = { os = "linux"; arch = "arm64";  hash = "sha256-hqLLiQOIRsKubKGUWlbqrUc7I/FFcn+dkj9tF0tDbyw="; };
        "armv7l-linux"   = { os = "linux"; arch = "armv7l"; hash = "sha256-1IyX6MdlPV9xiC7PTGzJYuR2vr5MhJ291LgSfdw0i34="; };
        "x86_64-darwin"  = { os = "macos"; arch = "amd64";  hash = "sha256-1IyX6MdlPV9xiC7PTGzJYuR2vr5MhJ291LgSfdw0i34="; };
        "aarch64-darwin" = { os = "macos"; arch = "arm64";  hash = "sha256-8a1sEzrm5GkEr02BpV9BU4LGt+uD34OD3q6pDJt/1Yo="; };
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
