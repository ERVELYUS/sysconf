{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  systemd.services.libvirtd-default-network = {
    description = "Start libvirt default network";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      ${pkgs.libvirt}/bin/virsh net-define /run/libvirt/network/default.xml 2>/dev/null || true
      ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
      ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
    '';
  };
}
