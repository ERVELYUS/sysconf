# swayidle.nix
{ pkgs, ... }:
let
  lockAndWait = pkgs.writeShellScript "lock-and-wait" ''
    ${pkgs.hyprlock}/bin/hyprlock &
    HYPRLOCK_PID=$!

    for i in $(seq 1 50); do
      if ${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null; then
        break
      fi
      sleep 0.1
    done

    sleep 0.5
  '';
in
{
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${pkgs.hyprlock}/bin/hyprlock";
    };
    timeouts = [
      {
        timeout = 300;
        command = "${lockAndWait}";
      }
      {
        timeout = 330;
        command = "/run/current-system/sw/bin/niri msg action power-off-monitors";
        resumeCommand = "/run/current-system/sw/bin/niri msg action power-on-monitors";
      }
    ];
  };
}
