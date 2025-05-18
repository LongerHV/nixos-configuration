{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;
    acceleration = "rocm";
  };
}
