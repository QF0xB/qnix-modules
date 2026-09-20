# Hyprland Keymap

The default modifier is `Super`. VM contexts use `Alt` instead. Key names below
are intentionally left as Hyprland key names or physical `code:` values. Use
`wev` on the target keyboard before translating the physical codes.

## Physical Key Translation

The QWERTZ and QWERTY columns come from actual `wev` output on the target
machine. Do not infer them from the numeric code: the compositor, keyboard
firmware, and active layout determine the result.

| Code | QWERTZ key | QWERTY key |
| --- | --- | --- |
| `code:10` | `1` | `1` |
| `code:11` | `2` | `2` |
| `code:12` | `3` | `3` |
| `code:13` | `4` | `4` |
| `code:14` | `5` | `5` |
| `code:15` | `6` | `6` |
| `code:16` | `7` | `7` |
| `code:17` | `8` | `8` |
| `code:18` | `9` | `9` |
| `code:19` | `0` | `0` |
| `code:20` | `ß` | `-` |
| `code:21` | `dead_acute` | `=` |
| `code:22` | `Backspace` | `Backspace` |
| `code:23` | `Tab` | `Tab` |
| `code:24` | `q` | `q` |
| `code:25` | `w` | `w` |
| `code:26` | `e` | `e` |
| `code:27` | `r` | `r` |
| `code:28` | `t` | `t` |
| `code:29` | `z` | `y` |
| `code:30` | `u` | `u` |
| `code:31` | `i` | `i` |
| `code:32` | `o` | `o` |
| `code:33` | `p` | `p` |
| `code:34` | `ü` | `[` |
| `code:35` | `+` | `]` |
| `code:36` | `Return` | `Return` |
| `code:37` | `Ctrl` | `Ctrl` |
| `code:38` | `a` | `a` |
| `code:39` | `s` | `s` |
| `code:40` | `d` | `d` |
| `code:41` | `f` | `f` |
| `code:42` | `g` | `g` |
| `code:43` | `h` | `h` |
| `code:44` | `j` | `j` |
| `code:45` | `k` | `k` |
| `code:46` | `l` | `l` |
| `code:47` | `ö` | `;` |
| `code:48` | `ä` | `'` |
| `code:49` | `dead_circumflex` | `` ` `` |
| `code:50` | `Shift` | `Shift` |
| `code:51` | `#` | `\\` |
| `code:52` | `y` | `z` |
| `code:53` | `x` | `x` |
| `code:54` | `c` | `c` |
| `code:55` | `v` | `v` |
| `code:56` | `b` | `b` |
| `code:57` | `n` | `n` |
| `code:58` | `m` | `m` |
| `code:59` | `,` | `,` |
| `code:60` | `.` | `.` |
| `code:61` | `-` | `/` |
| `code:62` | `Shift` | `Shift` |
| `code:65` | `Space` | `Space` |

## Applications

| Shortcut | Action |
| --- | --- |
| `mod+return` | Toggle scratchpad terminal in `special:scratch` |
| `mod+SHIFT+code:24` | Open the OpenCode folder picker in `special:scratch` |
| `mod+SHIFT+return` | Open a normal terminal |
| `mod+CTRL+return` | Open a floating terminal |
| `mod+code:25` | Toggle application launcher |
| `mod+CTRL+code:47` | Open a private Brave window |
| `mod+code:47` | Open Brave |
| `mod+code:29` | Toggle OBS |
| `mod+code:40` | Open Yazi in workspace 9 |
| `mod+code:57` | Toggle Bitwarden |
| `mod+code:26` | Toggle Obsidian |
| `mod+code:43` | Toggle Tidal HiFi |
| `mod+code:39` | Toggle the messenger workspace |

## Window Management

| Shortcut | Action |
| --- | --- |
| `mod+code:48` | Toggle fullscreen |
| `mod+code:38` | Close the focused window |
| `mod+SHIFT+code:48` | Toggle floating |
| `mod+code:61` | Toggle the current split layout |
| `mod+left/right/up/down` | Focus in the corresponding direction |
| `SUPER+Tab` | Swap with the next window |
| `ALT+Tab` | Cycle to the next window |
| `CTRL+Tab` | Focus the next workspace |

## Workspaces

`mod+1` through `mod+0` focus workspaces 1 through 10. The same shortcuts with
`CTRL` move the focused window without following it. The same shortcuts with
`CTRL+SHIFT` move the focused window and follow it.

The additional physical-code workspace bindings are:

| Workspace | Focus | Move | Move and follow |
| --- | --- | --- | --- |
| 1 | `mod+code:58` | `mod+CTRL+code:58` | `mod+SHIFT+CTRL+code:58` |
| 2 | `mod+code:59` | `mod+CTRL+code:59` | `mod+SHIFT+CTRL+code:59` |
| 3 | `mod+code:60` | `mod+CTRL+code:60` | `mod+SHIFT+CTRL+code:60` |
| 4 | `mod+code:44` | `mod+CTRL+code:44` | `mod+SHIFT+CTRL+code:44` |
| 5 | `mod+code:45` | `mod+CTRL+code:45` | `mod+SHIFT+CTRL+code:45` |
| 6 | `mod+code:46` | `mod+CTRL+code:46` | `mod+SHIFT+CTRL+code:46` |
| 7 | `mod+code:30` | `mod+CTRL+code:30` | `mod+SHIFT+CTRL+code:30` |
| 8 | `mod+code:31` | `mod+CTRL+code:31` | `mod+SHIFT+CTRL+code:31` |
| 9 | `mod+code:32` | `mod+CTRL+code:32` | `mod+SHIFT+CTRL+code:32` |
| 10 | `mod+code:65` | `mod+CTRL+code:65` | `mod+SHIFT+CTRL+code:65` |

## System

| Shortcut | Action |
| --- | --- |
| `mod+SHIFT+code:53` | Stop the user session |
| `mod+SHIFT+code:26` | Reload Hyprland |
| `mod+code:42` | Cycle the keyboard layout |

## Media And Hardware

| Shortcut | Action |
| --- | --- |
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play or pause media |
| `XF86AudioNext` | Next media track |
| `XF86AudioPrev` | Previous media track |
| `XF86AudioStop` | Stop media |
| `XF86MonBrightnessUp` | Increase brightness on laptops |
| `XF86MonBrightnessDown` | Decrease brightness on laptops |
