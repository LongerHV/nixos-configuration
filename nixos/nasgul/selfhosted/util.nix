{ config, ... }:

{
  traefik_router = { subdomain, local ? true, middlewares ? [ ] }:
    let
      domain = if local then "${subdomain}.local.${config.myDomain}" else "${subdomain}.${config.myDomain}";
      whitelist = if local then "local-ip-whitelist" else "external-ip-whitelist";
    in
    {
      rule = "Host(`${domain}`)";
      service = "${subdomain}_service";
      middlewares = middlewares ++ [ whitelist ];
    };
  traefik_service = { port, url ? "localhost" }:
    {
      loadBalancer = {
        servers = [
          { url = "http://${url}:${builtins.toString port}"; }
        ];
      };
    };
}
