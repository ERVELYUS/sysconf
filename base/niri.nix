{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

{
  imports = [
    ./common/desktop.nix
  ];

  # --- GREETER / SESSION
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = username;
      };
    };
  };

  # --- WAYLAND & COMPOSITOR
  programs.niri.enable = true;

  # --- NIRI-SPECIFIC PACKAGES
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    rofi
    clipse
    wl-clipboard
    thunar
    thunar-volman
    thunar-archive-plugin
    loupe

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
