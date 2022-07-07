_:

{
  # Databases:
  # 0: Authelia
  # 1: Gitea
  # 2: Blocky
  services.redis.servers."" = {
    enable = true;
    databases = 3;
    port = 0;
  };
}
