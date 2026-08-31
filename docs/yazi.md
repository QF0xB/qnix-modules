# Yazi guide

Yazi is enabled by the `apps.file-manager` feature. It integrates with Fish and
Zsh, so running `yazi` from either shell opens the file manager and returns to
the directory selected when Yazi exits.

## Everyday navigation

| Key | Action |
| --- | --- |
| `j` / `k` | Move down / up |
| `h` | Go to the parent directory, skipping directories that contain only one child |
| `l` | Open the selected item or enter a directory, skipping single-child directories |
| `f` | Jump to a file by typing its first character |
| `/` | Search files in the current directory |
| `g h` | Go to the home directory |
| `q` | Quit |

Yazi's normal selection and file-operation bindings remain available: use
`Space` to select, `y` to copy, `x` to cut, `d` to trash, and `p` to paste.
The configured `p` binding is smart: it pastes into the selected directory, or
into the current directory when a file is selected.

## Configured actions

| Key | Action |
| --- | --- |
| `T` | Maximise or restore the preview pane |
| `c m` | Change permissions for selected files |
| `C` | Create an archive with Ouch |
| `g t` | Open Yazi's native Trash view |
| `M m` | Choose a GVFS device, mount it, and enter it |
| `M u` | Choose a GVFS device to unmount |
| `M U` | Choose a GVFS device to unmount and eject |

The first key in combinations such as `c m` or `M m` is a prefix: press the
keys in sequence, not simultaneously.

## Archives, Trash, devices, and Git

Archives are previewed and can be extracted with the `extract` action using
Ouch. `C` opens Ouch's compression flow, which lets you choose the archive
format and destination.

`d` moves selected items to the Trash. Use `g t` to browse it, select one or
more files, and use Yazi's shown actions to restore or permanently delete them.
The native Trash view replaces the unreliable `recycle-bin` plugin. `trash-cli`
remains available for terminal use outside Yazi.

Mounted devices are managed through GVFS, the same desktop mounting layer used
by graphical applications. This is appropriate for USB drives, phones, network
shares, and other removable devices. The mount actions above do not require
manually finding a mount path.

Yazi also displays Git status information for files and directories. This is
read-only metadata: use Git itself for staging, committing, and other changes.

## Persistence

With the QNix impermanence setup, Yazi keeps its state in these persisted
paths:

- `~/.local/share/yazi`
- `~/.local/state/yazi`
- `~/.local/share/Trash`

This preserves Yazi's data and state across root filesystem resets. Its Nix
configuration is generated declaratively and is therefore not persisted as a
writable configuration directory.
