{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # --- HARDWARE
  hardware.bluetooth.enable = true;

  # --- DESKTOP SERVICES (GUI integration, irrelevant on a headless box)
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  # --- KEYBOARD LAYOUT (X11/Xwayland compat layer; Wayland-native compositors
  # like niri read their own layout from dotfiles, but this covers anything
  # using XWayland underneath, and is the standard place KDE/SDDM read it from)
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
    variant = "";
  };

  # --- PORTALS (needed by any Wayland or XDG-aware GUI app for file pickers, screenshare, etc.)
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  environment.sessionVariables = {
    GTK_CSD = "0";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  # --- SHARED GUI PACKAGES (apps that don't care which DE/compositor is running)
  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    v2rayn
    telegram-desktop
    spotify
    qbittorrent
    localsend
    vlc
    bitwarden-desktop
    gnome-calculator
    obsidian
    vesktop
    onlyoffice-desktopeditors
    qdirstat

    # Cursors & Icons
    bibata-cursors
    adwaita-icon-theme
  ];
}
