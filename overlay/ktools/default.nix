{ python3Packages, ... }:

with python3Packages;
buildPythonApplication {
  pname = "ktools";
  version = "1.0";
  pyproject = true;

  propagatedBuildInputs = [
    click
    pyyaml
    dacite
    cryptography
    rich
    kubernetes-asyncio
  ];

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  src = ./.;
}
