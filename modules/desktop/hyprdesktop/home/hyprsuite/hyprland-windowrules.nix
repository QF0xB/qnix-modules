{
  osConfig,
  lib,
  ...
}:

let
  cfg = osConfig.qnix.desktop.hyprdesktop;

  # New syntax: list of windowrule values (no "windowrule = " prefix; settings adds it)
  rules = [
    # --- Modal dialogs ------------------------------------
    "match:modal true, float on, center on, dim_around on, stay_focused on"

    # --- File pickers & portals ---------------------------
    "match:title ^(Open File|Save File|Choose File|File Upload|Open|Save As).*$, float on"

    # --- Generic auth prompts -----------------------------
    "match:title ^(Authentication Required|Permission required).*$, float on, center on, stay_focused on"

    # --- Auth / pinentry / keyring ------------------------
    "match:class ^(pinentry-|gcr-prompter).*$, stay_focused on"
    "match:class ^(pinentry-|gcr-prompter).*$, float on, center on, dim_around on"

    # --- Picture-in-Picture -------------------------------
    "match:title ^(Picture-in-Picture|Picture in picture)$, float on, pin on, keep_aspect_ratio on, no_blur on, no_shadow on, size 30% 30%, move (monitor_w-(window_w+21)) 58"

    # --- Small utility apps ------------------------------
    "match:class ^(qalculate-gtk|org.gnome.Calculator)$, float on, center on, size 520 620"
    "match:class ^(org\\.pulseaudio\\.)?pavucontrol$, float on, center on, size 900 650"
    "match:class ^\\.?blueman-manager(-wrapped)?$, float on, center on, size 900 650"
    "match:class ^(nm-connection-editor)$, float on, center on, size 900 650"

    # --- Steam quirks -------------------------------------
    "match:class ^steam$, match:title ^(Friends List|Steam Friends List).*$, float on, size 420 900, move (monitor_w-(window_w+24)) (monitor_h*0.12), focus_on_activate off"

    # --- IDE Quirk ---------------------------------------
    # "match:class ^(jetbrains-.*)$, match:float on, stay_focused on"

    # --- Tags ---------------------------------------------
    "match:class ^(ghostty|footclient|kitty|Alacritty)$, tag +term"
    "match:class ^(code|cursor|codium|jetbrains-.*)$, tag +code"
    "match:class ^(brave-browser|google-chrome)$, tag +browser"
    "match:class ^(tidal-hifi)$, tag +music"
    "match:class ^(nemo|thunar)$, tag +files"
    "match:class ^(Bitwarden)$, tag +passwords"
    "match:class ^(signal|discord)$, tag +messenger"
    "match:class ^(obsidian)$, tag +notes"
    "match:class ^(obs|com\\.obsproject\\.Studio)$, tag +obs"

    # --- Sensitive windows --------------------------------
    "match:class ^Bitwarden$, no_screen_share on"
    "match:class ^(pinentry-|gcr-prompter).*$, no_screen_share on"

    # --- Workspace placement ------------------------------
    "match:tag code, workspace 1"
    "match:tag term, workspace 2"
    "match:tag browser, workspace 3"
    "match:tag files, workspace 9"
    "match:tag music, workspace special:music"
    "match:class ^(scratchpad)$, workspace special:scratch"
    "match:tag messenger, workspace special:messenger"
    "match:tag notes, workspace special:notes"
    "match:tag obs, workspace special:obs"
    "match:tag passwords, workspace special:secrets"
  ];
in
lib.mkIf (cfg.enable && cfg.hyprsuite.hyprland.setDefaultWindowRules) {
  wayland.windowManager.hyprland.settings = {
    windowrule = rules;
  };
}
