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

  # --- DISPLAY MANAGER / DESKTOP
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- KDE-SPECIFIC PACKAGES
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.gwenview
  ];

  # Stylix has a dedicated Plasma target — keeps theming consistent with
  # the rest of the fleet without manual Plasma color-scheme setup.
  stylix.targets.plasma.enable = true;
}
