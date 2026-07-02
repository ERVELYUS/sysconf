{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

{
  imports = [
    ./hardware.nix
  ];

  # --- IDENTITY
  networking.hostName = "whale";

  # --- BOOTLOADER
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # --- DISK ENCRYPTION (swap device — root LUKS device lives in hardware.nix, untouched)
  boot.initrd.luks.devices."luks-8026dd34-9a55-48ee-8753-cfc0246f97b9".device =
    "/dev/disk/by-uuid/8026dd34-9a55-48ee-8753-cfc0246f97b9";

  # --- USER ACCOUNT
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "26.05";
}
