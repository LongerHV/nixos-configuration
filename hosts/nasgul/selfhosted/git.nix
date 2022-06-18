_:

{
  services.gitea = {
    enable = true;
    repositoryRoot = "/chonk/repositories";
    database = {
      type = "mysql";
      socket = "/run/mysqld/mysqld.sock";
    };
  };
}
