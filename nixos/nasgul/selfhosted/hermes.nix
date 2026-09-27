{ config, inputs, pkgs, ... }:

let
  inherit (config.age) secrets;
  hermesUid = 950;
  # podman.socket is enabled for all users by virtualisation.podman; the
  # gateway unit (NoNewPrivileges, ProtectSystem=strict) cannot run podman
  # itself, so it talks to the API socket in the lingering hermes user manager.
  podmanSocket = "unix:///run/user/${toString hermesUid}/podman/podman.sock";
in
{
  imports = [ inputs.hermes-agent.nixosModules.default ];

  age.secrets.hermes_env.file = ../../../secrets/nasgul_hermes_env.age;

  users.users = {
    hermes = {
      uid = hermesUid;
      # Rootless podman needs subordinate ids; only normal users get them by default.
      autoSubUidGidRange = true;
    };
    "${config.mySystem.user}".extraGroups = [ "hermes" ];
  };

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [ secrets.hermes_env.path ];
    extraPackages = [ pkgs.podman ];
    environment = {
      # CONTAINER_HOST makes podman default to --remote.
      CONTAINER_HOST = podmanSocket;
      # Hermes prefers `docker` from PATH, and interactive shells on nasgul see
      # the rootful docker CLI; pin podman for both the gateway and the CLI.
      HERMES_DOCKER_BINARY = "${pkgs.podman}/bin/podman";
    };
    settings = {
      model = {
        provider = "anthropic";
        default = "claude-sonnet-5";
      };
      terminal = {
        backend = "docker";
        docker_persist_across_processes = true;
        # terminal.cwd is the host workingDirectory; bind it at /workspace so
        # the sandbox has a real, persistent workdir.
        docker_mount_cwd_to_workspace = true;
        container_cpu = 4;
        container_memory = 8192;
      };
    };
  };
}
