{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.hyprland" ];

  options =
    { lib, ... }:
    {
      additionalRules = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
        description = "Additional native Hyprland Lua window rules.";
      };
    };

  home =
    { cfg, ... }:
    {
      wayland.windowManager.hyprland.settings.window_rule = [
        {
          name = "modal-dialogs";
          match.modal = true;
          float = true;
          center = true;
          dim_around = true;
          stay_focused = true;
        }
        {
          name = "file-dialogs";
          match.title = "^(Open File|Save File|Choose File|File Upload|Open|Save As).*$";
          float = true;
        }
        {
          name = "authentication-dialogs";
          match.title = "^(Authentication Required|Permission required).*$";
          float = true;
          center = true;
          stay_focused = true;
        }
        {
          name = "authentication-prompters";
          match.class = "^(pinentry-|gcr-prompter).*$";
          float = true;
          center = true;
          dim_around = true;
          stay_focused = true;
          no_screen_share = true;
        }
        {
          name = "picture-in-picture";
          match.title = "^(Picture-in-Picture|Picture in picture)$";
          float = true;
          pin = true;
          keep_aspect_ratio = true;
          no_blur = true;
          no_shadow = true;
          size = "30% 30%";
          move = "(monitor_w-(window_w+21)) 58";
        }
        {
          name = "calculator";
          match.class = "^(qalculate-gtk|org.gnome.Calculator)$";
          float = true;
          center = true;
          size = "520 620";
        }
        {
          name = "pavucontrol";
          match.class = "^(org\\.pulseaudio\\.)?pavucontrol$";
          float = true;
          center = true;
          size = "900 650";
        }
        {
          name = "blueman";
          match.class = "^\\.?blueman-manager(-wrapped)?$";
          float = true;
          center = true;
          size = "900 650";
        }
        {
          name = "networkmanager-editor";
          match.class = "^(nm-connection-editor)$";
          float = true;
          center = true;
          size = "900 650";
        }
        {
          name = "steam-friends";
          match = {
            class = "^steam$";
            title = "^(Friends List|Steam Friends List).*$";
          };
          float = true;
          size = "420 900";
          move = "(monitor_w-(window_w+24)) (monitor_h*0.12)";
          focus_on_activate = false;
        }
        {
          name = "tag-terminals";
          match.class = "^(ghostty|footclient|kitty|Alacritty)$";
          tag = "+term";
        }
        {
          name = "tag-editors";
          match.class = "^(code|codium|jetbrains-.*)$";
          tag = "+code";
        }
        {
          name = "tag-browsers";
          match.class = "^(brave-browser|google-chrome)$";
          tag = "+browser";
        }
        {
          name = "tag-music";
          match.class = "^(tidal-hifi)$";
          tag = "+music";
        }
        {
          name = "tag-file-managers";
          match.class = "^(nemo|thunar)$";
          tag = "+files";
        }
        {
          name = "tag-bitwarden";
          match.class = "^(Bitwarden)$";
          tag = "+passwords";
          no_screen_share = true;
        }
        {
          name = "tag-messengers";
          match.class = "^(signal|discord)$";
          tag = "+messenger";
        }
        {
          name = "tag-notes";
          match.class = "^(obsidian)$";
          tag = "+notes";
        }
        {
          name = "tag-obs";
          match.class = "^(obs|com\\.obsproject\\.Studio)$";
          tag = "+obs";
        }
        {
          name = "code-workspace";
          match.tag = "code";
          workspace = "1";
        }
        {
          name = "terminal-workspace";
          match.tag = "term";
          workspace = "2";
        }
        {
          name = "browser-workspace";
          match.tag = "browser";
          workspace = "3";
        }
        {
          name = "files-workspace";
          match.tag = "files";
          workspace = "9";
        }
        {
          name = "music-workspace";
          match.tag = "music";
          workspace = "special:music";
        }
        {
          name = "scratchpad-workspace";
          match.class = "^(scratchpad)$";
          workspace = "special:scratch";
        }
        {
          name = "messenger-workspace";
          match.tag = "messenger";
          workspace = "special:messenger";
        }
        {
          name = "notes-workspace";
          match.tag = "notes";
          workspace = "special:notes";
        }
        {
          name = "obs-workspace";
          match.tag = "obs";
          workspace = "special:obs";
        }
        {
          name = "passwords-workspace";
          match.tag = "passwords";
          workspace = "special:secrets";
        }
      ]
      ++ cfg.additionalRules;
    };
}
