{ config, lib, pkgs, ... }:

{
  # No GUI, no greetd, no desktop integration — core.nix already
  # provides SSH, CLI tools, and stylix (terminal-app theming only).

  # --- HEADLESS-SPECIFIC HARDENING ---
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";

  # Headless boxes don't need a splash screen or plymouth animation.
  boot.plymouth.enable = lib.mkForce false;
}
