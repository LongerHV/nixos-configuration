_:

{
  # Databases:
  # 0: Authelia
  services.redis.servers."" = {
    enable = true;
    databases = 1;
    port = 0;
  };
}
