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
    }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      # To update: change version, then set both hashes to "" and build.
      # The error messages will contain the correct hashes.
      # Release tags: https://github.com/coder/code-server/releases
      version = "4.109.2";

      src =
        let
          sources = {
            "x86_64-linux" = pkgs.fetchurl {
              url = "https://github.com/coder/code-server/releases/download/v${version}/code-server-${version}-linux-amd64.tar.gz";
              hash = "sha256-PlT5G09+LM8v4U4w/c74gxfIPdvgbRrypbhTKZb/vh4=";
            };
            "aarch64-linux" = pkgs.fetchurl {
              url = "https://github.com/coder/code-server/releases/download/v${version}/code-server-${version}-linux-arm64.tar.gz";
              hash = "sha256-JxrG7CTHKDlX/clY/hlsUXThfqZxOZd7reTKjzHFDww=";
            };
          };
        in
          sources.${system} or (throw "Unsupported system: ${system}");

      archSuffix = {
        "x86_64-linux" = "amd64";
        "aarch64-linux" = "arm64";
      }.${system} or (throw "Unsupported system: ${system}");
    in
    {
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "code-server";
        inherit version src;

        sourceRoot = "code-server-${version}-linux-${archSuffix}";

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
          platforms = [ "x86_64-linux" "aarch64-linux" ];
        };
      };
    });
}
