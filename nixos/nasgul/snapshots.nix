{
  services.sanoid = {
    enable = true;
    interval = "daily";
    templates.default = {
      hourly = 0;
      daily = 14;
      monthly = 3;
      yearly = 0;
    };
    datasets = {
      "rpool/root" = {
        useTemplate = [ "default" ];
      };
      "rpool/root/var" = {
        useTemplate = [ "default" ];
      };
      "chonk" = {
        useTemplate = [ "default" ];
        recursive = true;
      };
    };
  };
  services.syncoid = {
    enable = true;
  };
}
