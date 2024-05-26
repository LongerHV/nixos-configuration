{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs;[
    air
    go
    golangci-lint
    gopls
    templ
  ];
}
