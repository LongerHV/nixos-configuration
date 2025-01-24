{ pkgs, ... }:

pkgs.mkShell {
  buildInputs = with pkgs.python3Packages; [
    python
    venvShellHook
    pkgs.pkg-config
    pkgs.libmysqlclient
  ];
  venvDir = "./.venv";
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
  '';
  postShellHook = ''
    unset SOURCE_DATE_EPOCH
  '';
}
