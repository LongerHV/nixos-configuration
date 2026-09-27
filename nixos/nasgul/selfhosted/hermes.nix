{ config, inputs, pkgs, ... }:

let
  inherit (config.age) secrets;
  hermesUid = 950;
  # podman.socket is enabled for all users by virtualisation.podman; the
  # gateway unit (NoNewPrivileges, ProtectSystem=strict) cannot run podman
  # itself, so it talks to the API socket in the lingering hermes user manager.
  podmanSocket = "unix:///run/user/${toString hermesUid}/podman/podman.sock";
  inherit (config.homelab) domain;
  dashboardPort = 9119;
  dashboardUrl = "https://hermes.${domain}";
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

  homelab.traefik.services.hermes.port = dashboardPort;

  # Podman image storage under /var/lib/hermes/.local is reproducible and excluded.
  homelab.backups.services.hermes.paths = [
    "/var/lib/hermes/.hermes"
    "/var/lib/hermes/workspace"
  ];

  services.authelia.instances.main.settings.identity_providers.oidc = {
    # The dashboard can read and edit API keys: admins only.
    authorization_policies.hermes = {
      default_policy = "deny";
      rules = [{
        policy = "one_factor";
        subject = "group:admin";
      }];
    };
    clients = [{
      client_id = "hermes-dashboard";
      client_name = "Hermes";
      public = true;
      token_endpoint_auth_method = "none";
      require_pkce = true;
      pkce_challenge_method = "S256";
      authorization_policy = "hermes";
      redirect_uris = [ "${dashboardUrl}/auth/callback" ];
      scopes = [ "openid" "profile" "email" ];
    }];
  };

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [ secrets.hermes_env.path ];
    extraPackages = [ pkgs.podman ];
    backend = {
      mode = "dashboard";
      host = "127.0.0.1";
      port = dashboardPort;
    };
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
      dashboard = {
        # Required so the dashboard accepts the proxied Host header; it also
        # engages the auth gate, served by the self_hosted OIDC plugin.
        public_url = dashboardUrl;
        trusted_proxies = [ "127.0.0.1" ];
        oauth.self_hosted = {
          issuer = "https://auth.${domain}";
          client_id = "hermes-dashboard";
        };
      };
    };
  };
}
