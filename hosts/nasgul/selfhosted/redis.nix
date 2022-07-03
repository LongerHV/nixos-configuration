_:

{
  # Databases:
  # 0: Authelia
  # 1: Gitea
  services.redis.servers."" = {
    enable = true;
    databases = 2;
    port = 0;
  };
}
