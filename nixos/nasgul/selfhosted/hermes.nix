{ config, inputs, ... }:

let
  inherit (config.age) secrets;
  hermesUid = 950;
in
{
  imports = [ inputs.hermes-agent.nixosModules.default ];

  age.secrets.hermes_env.file = ../../../secrets/nasgul_hermes_env.age;

  users.users = {
    hermes.uid = hermesUid;
    "${config.mySystem.user}".extraGroups = [ "hermes" ];
  };

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [ secrets.hermes_env.path ];
    settings.model = {
      provider = "anthropic";
      default = "claude-sonnet-5";
    };
  };
}
