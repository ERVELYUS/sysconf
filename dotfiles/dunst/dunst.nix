{
  config,
  pkgs,
  lib,
  ...
}:

{
  stylix.targets.dunst.enable = true;

  services.dunst = {
    enable = true;
    package = pkgs.dunst;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";

        # --- Geometry / placement
        width = "(400, 550)";
        height = 300;
        origin = "top-right";
        offset = "20x20";
        scale = 0;
        notification_limit = 20;

        # --- Layer shell (Wayland)
        layer = "overlay";

        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = lib.mkForce 0;

        indicate_hidden = "yes";
        transparency = 5;
        separator_height = 2;
        padding = 16;
        horizontal_padding = 16;
        text_icon_padding = 16;

        frame_width = 2;
        corner_radius = lib.mkForce 0;

        gap_size = 8;

        sort = "yes";
        idle_threshold = 120;

        font = lib.mkForce "JetBrainsMono Nerd Font Mono 11";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";

        icon_position = "left";
        min_icon_size = 0;
        max_icon_size = 64;

        sticky_history = "yes";
        history_length = 20;

        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";
        browser = "${pkgs.xdg-utils}/bin/xdg-open";

        always_run_script = true;
        title = "Dunst";
        class = "Dunst";

        ignore_dbusclose = false;

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      experimental = {
        per_monitor_dpi = false;
      };

      urgency_low = {
        timeout = 4;
      };

      urgency_normal = {
        timeout = 6;
      };

      urgency_critical = {
        timeout = 0;
      };
    };
  };

  home.packages = [ pkgs.dunst ];

  home.shellAliases = {
    noti-history = "dunstctl history-pop";
    noti-dnd-toggle = "dunstctl set-paused toggle";
    noti-close-all = "dunstctl close-all";
  };
}
