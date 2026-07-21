{
  pkgs,
  config,
  username,
  ...
}:

{
  # --- BASIC HOME SETTINGS
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";
  home.pointerCursor.enable = true;

  programs.home-manager.enable = true;

  imports = [
    ./rofi/rofi.nix
    ./ghostty/ghostty.nix
    ./zsh/zsh.nix
    ./swayidle/swayidle.nix
    ./hyprlock/hyprlock.nix
  ];

  # --- SYMLINKS
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/nvim";
  xdg.configFile."niri".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/niri";
  xdg.configFile."noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/noctalia/settings.toml";

  xdg.configFile."clipse/config.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/clipse/config.json";
  xdg.configFile."fastfetch/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/fastfetch/config.jsonc";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "thunar.desktop";
      "text/plain" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "application/x-yaml" = "nvim.desktop";
    };
  };
  xfconf.settings.thunar = {
    "default-view" = "ThunarDetailsView"; # list view
    "last-view" = "ThunarDetailsView";
    "misc-single-click" = false;
  };
  home.file.".config/xfce4/helpers.rc".text = "TerminalEmulator=ghostty";

  # --- DESKTOP ENTRIES
  xdg.desktopEntries = {
    btop = {
      name = "btop++";
      noDisplay = true;
    };
    nvim = {
      name = "Neovim wrapper";
      exec = "ghostty -e nvim %F";
      terminal = false;
      noDisplay = true;
      mimeType = [
        "text/plain"
        "text/markdown"
        "text/x-shellscript"
        "text/x-python"
        "application/json"
        "application/x-yaml"
        "text/x-csrc"
        "text/x-nix"
      ];
    };
    "nixos-manual" = {
      name = "NixOS Manual";
      noDisplay = true;
    };
    qt5ct = {
      name = "Qt5 Settings";
      noDisplay = true;
    };
    qt6ct = {
      name = "Qt6 Settings";
      noDisplay = true;
    };
    kvantummanager = {
      name = "Kvantum Manager";
      noDisplay = true;
    };
    rofi = {
      name = "Rofi";
      noDisplay = true;
    };
    rofi_themes = {
      name = "Rofi Theme Selector";
      noDisplay = true;
    };
    "thunar-bulk-rename" = {
      name = "Thunar Bulk Rename";
      noDisplay = true;
    };
    "thunar-settings" = {
      name = "Thunar Preferences";
      noDisplay = true;
    };
    "thunar-volman-settings" = {
      name = "Removable Drives and Media";
      noDisplay = true;
    };
    "dev.noctalia.Noctalia" = {
      name = "Noctalia";
      noDisplay = true;
    };
  };

  # Force override rofi's own desktop files
  xdg.configFile."rofi-hide-rofi.desktop".text = "";
  home.file.".local/share/applications/rofi.desktop".text =
    "[Desktop Entry]\nNoDisplay=true\nName=Rofi\nType=Application\nExec=rofi";
  home.file.".local/share/applications/rofi-theme-selector.desktop".text =
    "[Desktop Entry]\nNoDisplay=true\nName=Rofi Theme Selector\nType=Application\nExec=rofi-theme-selector";
}
