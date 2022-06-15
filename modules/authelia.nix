{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.authelia;
  opt = options.services.authelia;
  rootDir = "/var/lib/authelia";
  configFile = builtins.toJSON cfg.settings;
  configFilePath = "/etc/authelia/configuration.yml";
in
{
  options.services.authelia = {
    enable = mkEnableOption "authelia";
    jwtSecretFile = mkOption {
      type = types.path;
    };
    image = mkOption {
      type = types.str;
      default = "authelia/authelia:4.35.6";
    };
    storageEncryptionKeyFile = mkOption {
      type = types.path;
    };
    port = mkOption {
      type = types.int;
      default = 9092;
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      authelia = rec {
        inherit (cfg) image;
        cmd = [ "--config" "/etc/authelia/configuration.yml" ];
        ports = [ "${builtins.toString cfg.port}:9092" ];
        environment = {
          AUTHELIA_JWT_SECRET_FILE = "/run/jwt_secret";
          AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = "/run/storage_encryption_file";
        };
        volumes = [
          "${rootDir}:/config"
          "${configFilePath}:${configFilePath}"
          "${cfg.jwtSecretFile}:${environment.AUTHELIA_JWT_SECRET_FILE}"
          "${cfg.storageEncryptionKeyFile}:${environment.AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE}"
        ];
      };
    };
    environment.etc."authelia/configuration.yml" = {
      text = configFile;
    };
  };
}
