{ pkgs, ... }:

{
  programs.helix.languages = {
    language-server.docker-langserver = with pkgs.nodePackages; {
      command = "${dockerfile-language-server-nodejs}/bin/docker-langserver";
      args = [ "--stdio" ];
    };
    language = [
      {
        name = "dockerfile";
        scope = "source.dockerfile";
        injection-regex = "docker|dockerfile";
        roots = [ "Dockerfile" "Containerfile" ];
        file-types = [ "Dockerfile" "dockerfile" "Containerfile" "containerfile" ];
        comment-token = "#";
        indent = { tab-width = 2; unit = "  "; };
        language-servers = [ "docker-langserver" ];
      }
    ];
  };
}
