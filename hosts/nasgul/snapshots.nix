_:
{
  services.sanoid = {
    enable = true;
    templates.default = {
      monthly = 3;
      daily = 14;
    };
    datasets = {
      "rpool/root" = {
        useTemplate = [ "default" ];
        recursive = true;
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
