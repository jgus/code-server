# code-server Nix flake

Nix flake packaging [code-server](https://github.com/coder/code-server) (VS Code in the browser) from upstream release tarballs.

A GitHub Action checks daily for new releases and automatically updates the version, hashes, and tags.

## Usage

```nix
# flake.nix
{
  inputs.code-server.url = "github:jgus/code-server";

  # ...
  environment.systemPackages = [ inputs.code-server.packages.${system}.default ];
}
```

Or run directly:

```sh
nix run "github:jgus/code-server"
```

## Supported platforms

- `x86_64-linux`
- `aarch64-linux`
