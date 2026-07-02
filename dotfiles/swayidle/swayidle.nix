{
  ...
}:

{
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "/run/current-system/sw/bin/noctalia msg session lock";
    };
    timeouts = [
      {
        timeout = 300;
        command = "/run/current-system/sw/bin/noctalia msg session lock";
      }
      {
        timeout = 330;
        command = "/run/current-system/sw/bin/niri msg action power-off-monitors";
      }
    ];
  };
}
