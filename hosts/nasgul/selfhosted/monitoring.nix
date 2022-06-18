_:

{
  services.netdata = {
    enable = true;
    config.global = {
      "update every" = "15";
    };
  };
}
