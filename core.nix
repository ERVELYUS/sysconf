{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

let
  c = config.lib.stylix.colors;
  nixosLogo = import ./dotfiles/plymouth/mkLogo.nix {
    inherit pkgs;
    colors = c;
  };

  nixosPlymouthTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-nixos";
    version = "1.0";
    src = ./dotfiles/plymouth;
    nativeBuildInputs = [ pkgs.python3 ];
    installPhase = ''
            mkdir -p $out/share/plymouth/themes/nixos
            cp -r $src/* $out/share/plymouth/themes/nixos/
            rm -f $out/share/plymouth/themes/nixos/logo.png
            cp ${nixosLogo} $out/share/plymouth/themes/nixos/logo.png

            sed -i 's/[Oo]marchy/NixOS/g' \
              $out/share/plymouth/themes/nixos/nixos.script \
              $out/share/plymouth/themes/nixos/nixos.plymouth

            bgFloat=$(python3 -c "
      c = '${c.base00}'
      r,g,b = int(c[0:2],16)/255, int(c[2:4],16)/255, int(c[4:6],16)/255
      print(f'{r:.3f}, {g:.3f}, {b:.3f}')")

            sed -i "s/^Window.SetBackgroundTopColor(.*/Window.SetBackgroundTopColor($bgFloat);/" \
              $out/share/plymouth/themes/nixos/nixos.script
            sed -i "s/^Window.SetBackgroundBottomColor(.*/Window.SetBackgroundBottomColor($bgFloat);/" \
              $out/share/plymouth/themes/nixos/nixos.script
    '';
  };
in
{
  # --- GARBAGE COLLECTOR
  nix.optimise.automatic = true;

  # --- NIX SETTINGS
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # --- BOOT (host-specific bootloader/LUKS lives in hosts/<name>/configuration.nix)
  boot.tmp.cleanOnBoot = true;

  boot.plymouth = {
    enable = true;
    themePackages = [ nixosPlymouthTheme ];
    theme = "nixos";
  };

  boot.consoleLogLevel = 0;
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- NETWORKING
  networking.networkmanager.enable = false;
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
      };
    };
  };
  networking.firewall.enable = false;

  # --- HARDWARE
  hardware.bluetooth.enable = true;

  # --- SERVICES
  services.openssh.enable = true;
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
  security.pam.services.greetd.enableGnomeKeyring = true;

  # --- GREETER / SESSION
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = username;
      };
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = username;
      };
    };
  };

  # --- KEYBOARD LAYOUT
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
    variant = "";
  };

  # --- PORTALS
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

  # --- LOCALE & TIME
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # --- WAYLAND & COMPOSITOR
  programs.niri.enable = true;
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.nh = {
    enable = true;
    flake = "/home/${username}/sysconf";
    clean.enable = true;
    clean.extraArgs = "--keep-since 15d --keep 4";
  };

  # --- SHELL ALIASES
  environment.shellAliases = {
    os-switch = "nh os switch";
    os-update = "nh os switch --update";
    os-clean = "nh clean all --keep 3 && sudo /run/current-system/bin/switch-to-configuration boot";
    c = "clear";
  };

  # --- SYSTEM PACKAGES (CLI + GUI, everything lives together now)
  environment.systemPackages = with pkgs; [
    # CLI
    git
    gh
    curl
    unzip
    gzip
    gnumake
    gcc
    neovim
    nil
    wget
    fastfetch
    btop
    sshs
    tree-sitter
    nodejs_22
    python3
    go
    cargo
    nixfmt
    ripgrep
    gnupg
    nvd
    tree
    impala
    bluetui

    xwayland-satellite
    brightnessctl
    rofi
    clipse
    wl-clipboard
    thunar
    thunar-volman
    thunar-archive-plugin
    loupe
    inputs.noctalia.packages.${pkgs.system}.default

    # Desktop apps
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
    ghostty

    # Cursors & Icons
    bibata-cursors
    adwaita-icon-theme
  ];

  # --- FONTS
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.enable = true;

  # --- STYLIX
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/primer-dark.yaml";
    polarity = "dark";
    image = ./dotfiles/wallpaper/wallpaper.jpg;
    targets.plymouth.enable = false;
    opacity.terminal = 0.85;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sizes.terminal = 12;
    };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Original-Classic";
      size = 20;
    };
  };

  # --- SECURITY & MISC
  security.polkit.enable = true;
}
