{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    blender
    obs-studio
    inkscape
    gimp
    krita
    audacity
  ];
}
