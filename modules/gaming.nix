{ config, pkgs, ... }:

{
  # --- STEAM
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # --- PERFORMANCE
  programs.gamemode.enable = true;

  # --- CONTROLLERS
  hardware.xpadneo.enable = true;
  services.udev.packages = with pkgs; [ game-devices-udev-rules ];

  # --- GUI LAUNCHERS / TOOLS
  environment.systemPackages = with pkgs; [
    lutris
    heroic
    mangohud
    protonup-qt
  ];
}
