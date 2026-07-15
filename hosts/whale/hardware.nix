{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/luks-464396df-cf97-4247-80bd-77246d3967e0";
    fsType = "btrfs";
  };

  boot.initrd.luks.devices."luks-464396df-cf97-4247-80bd-77246d3967e0".device =
    "/dev/disk/by-uuid/464396df-cf97-4247-80bd-77246d3967e0";

  fileSystems."/home" = {
    device = "/dev/mapper/luks-464396df-cf97-4247-80bd-77246d3967e0";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/luks-464396df-cf97-4247-80bd-77246d3967e0";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6EF9-CE7E";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/mapper/luks-8026dd34-9a55-48ee-8753-cfc0246f97b9"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
