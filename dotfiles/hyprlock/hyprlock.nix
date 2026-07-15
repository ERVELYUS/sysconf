{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
  nixosLogo = import ../plymouth/mkLogo.nix {
    inherit pkgs;
    colors = c;
  };
in
{
  stylix.targets.hyprlock.enable = false;

  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          path = "${config.stylix.image}";
          color = "rgb(${c.base00})";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.6;
        }
      ];
      image = [
        {
          path = "${nixosLogo}";
          size = 250;
          rounding = 0;
          border_size = 0;
          position = "0, 150";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          size = "300, 60";
          rounding = 0;
          outer_color = "rgb(${c.base0D})";
          inner_color = "rgb(${c.base00})";
          font_color = "rgb(${c.base05})";
          position = "0, -100";
          halign = "center";
          valign = "center";
          placeholder_text = "type here...";
          fade_on_empty = "false";
        }
      ];
    };
  };
}
