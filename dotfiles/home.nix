{
  config,
  username,
  ...
}:

{
  # --- BASIC HOME SETTINGS
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  imports = [
    ./rofi/rofi.nix
    ./ghostty/ghostty.nix
    ./zsh/zsh.nix
    ./swayidle/swayidle.nix
  ];

  # --- SYMLINKS
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/nvim";
  xdg.configFile."niri".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/niri";
  xdg.configFile."clipse/config.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/clipse/config.json";
  home.file.".local/state/noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sysconf/dotfiles/noctalia/settings.toml";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "thunar.desktop";
    };
  };

  # --- DESKTOP ENTRIES
  xdg.desktopEntries = {
    btop = {
      name = "btop++";
      noDisplay = true;
    };
    nvim = {
      name = "Neovim wrapper";
      noDisplay = true;
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
