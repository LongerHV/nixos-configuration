{ pkgs, lib, ... }:

{
  options.homelab.auth = {
    # Authelia OIDC provider settings (clients, authorization_policies,
    # claims_policies) declared next to the services that use them, on
    # whichever host runs that service. The host running Authelia merges its
    # own with the other hosts' declarations.
    oidc = lib.mkOption {
      inherit (pkgs.formats.yaml { }) type;
      default = { };
    };
  };
}
