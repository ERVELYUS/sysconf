{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

{
  # --- GARBAGE COLLECTOR
  nix.optimise.automatic = true;

  # --- NIX SETTINGS
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # --- BOOT (universal — host-specific bootloader/LUKS lives in hosts/<name>/configuration.nix)
  boot.tmp.cleanOnBoot = true;

  boot.plymouth = {
    enable = true;
    theme = "spinner";
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
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # --- SERVICES
  services.openssh.enable = true;

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

  # --- NIXPKGS CONFIG
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  # --- SYSTEM PACKAGES (CLI, every host — including the server)
  environment.systemPackages = with pkgs; [
    git
    gh
    curl
    unzip
    gzip
    gnumake
    gcc
    neovim
    wget
    fastfetch
    btop
    sshs
    tree-sitter
    nodejs_22
    go
    cargo
    nixfmt
    ripgrep
    gnupg
    nvd
    tree
  ];

  # --- SHELL & SESSION
  environment.shellAliases = {
    os-switch = "nh os switch";
    os-update = "nh os switch --update";
    os-clean = "nh clean all --keep 3 && sudo /run/current-system/bin/switch-to-configuration boot";
    c = "clear";
  };

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

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # --- FONTS (kept universal — stylix references this on every host, server included)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.enable = true;

  # --- STYLIX (universal per request — applies on headless too, where it mainly
  # affects terminal-app colors like btop/fastfetch rather than any GUI)
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/primer-dark.yaml";
    polarity = "dark";
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-dracula.png";
      sha256 = "sha256-SykeFJXCzkeaxw06np0QkJCK28e0k30PdY8ZDVcQnh4=";
    };
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
