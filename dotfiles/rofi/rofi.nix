{
  config,
  pkgs,
  ...
}:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    extraConfig = {
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = "Run:";
    };

    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
        colors = config.lib.stylix.colors.withHashtag;
      in
      pkgs.lib.mkForce {
        "*" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral colors.base05;
          font = "JetBrainsMono Nerd Font Mono 12";
        };
        "window" = {
          width = mkLiteral "850px";
          height = mkLiteral "1000px";
          background-color = mkLiteral "${colors.base00}D9";
          border = mkLiteral "1px";
          border-color = mkLiteral colors.base0D;
          border-radius = mkLiteral "0px";
          padding = mkLiteral "20px";
        };
        "mainbox" = {
          children = mkLiteral "[ inputbar, listview ]";
          spacing = mkLiteral "15px";
        };
        "inputbar" = {
          children = mkLiteral "[ prompt, entry ]";
          background-color = mkLiteral colors.base01;
          border-radius = mkLiteral "8px";
          padding = mkLiteral "12px";
        };
        "prompt" = {
          text-color = mkLiteral colors.base0D;
          padding = mkLiteral "0 10px 0 0";
        };
        "entry" = {
          text-color = mkLiteral colors.base05;
          placeholder = "Search...";
          placeholder-color = mkLiteral colors.base03;
        };
        "listview" = {
          spacing = mkLiteral "5px";
          scrollbar = false;
        };
        "element" = {
          padding = mkLiteral "10px";
          border-radius = mkLiteral "6px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral colors.base05;
        };
        "element selected" = {
          background-color = mkLiteral colors.base02;
          text-color = mkLiteral colors.base0D;
        };
        "element-icon" = {
          size = mkLiteral "24px";
          padding = mkLiteral "0 15px 0 0";
          background-color = mkLiteral "transparent";
        };
        "element-text" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
        };
      };
  };
}
