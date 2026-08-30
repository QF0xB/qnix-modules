{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.xdg-folders" ];

  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      bookmark = name: path: if path == null then null else "file://${path} ${name}";
    in
    {
      gtk = {
        enable = true;
        gtk3 = {
          enable = true;
          bookmarks = lib.filter (entry: entry != null) [
            (bookmark "Home" config.home.homeDirectory)
            (bookmark "Projects" config.xdg.userDirs.projects)
            (bookmark "Documents" config.xdg.userDirs.documents)
            (bookmark "Downloads" config.xdg.userDirs.download)
            (bookmark "Music" config.xdg.userDirs.music)
            (bookmark "Pictures" config.xdg.userDirs.pictures)
            (bookmark "Videos" config.xdg.userDirs.videos)
          ];
        };
      };

      home.packages = [
        pkgs.nemo
      ];

      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;

        extraPackages = [
          pkgs.glib
          pkgs.gvfs
          pkgs.ouch
          pkgs.trash-cli
        ];

        plugins = {
          bypass.package = pkgs.yaziPlugins.bypass;
          chmod.package = pkgs.yaziPlugins.chmod;
          git = {
            package = pkgs.yaziPlugins.git;
            setup = true;
            settings.order = 1500;
          };
          gvfs = {
            package = pkgs.yaziPlugins.gvfs;
            setup = true;
          };
          jump-to-char.package = pkgs.yaziPlugins.jump-to-char;
          ouch.package = pkgs.yaziPlugins.ouch;
          recycle-bin = {
            package = pkgs.yaziPlugins.recycle-bin;
            setup = true;
          };
          smart-paste.package = pkgs.yaziPlugins.smart-paste;
          toggle-pane.package = pkgs.yaziPlugins.toggle-pane;
        };

        settings = {
          opener.extract = [
            {
              run = ''ouch d -y "$@"'';
              desc = "Extract here with ouch";
              for = "unix";
            }
          ];

          plugin = {
            prepend_fetchers = [
              {
                url = "*";
                run = "git";
                group = "git";
              }
              {
                url = "*/";
                run = "git";
                group = "git";
              }
            ];
            prepend_previewers = [
              {
                mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
                run = "ouch";
              }
            ];
          };
        };

        keymap.mgr.prepend_keymap = [
          {
            on = [ "h" ];
            run = "plugin bypass reverse";
            desc = "Leave and skip single-child directories";
          }
          {
            on = [ "l" ];
            run = "plugin bypass smart-enter";
            desc = "Open or enter and skip single-child directories";
          }
          {
            on = [ "p" ];
            run = "plugin smart-paste";
            desc = "Paste into the hovered directory or current directory";
          }
          {
            on = [ "f" ];
            run = "plugin jump-to-char";
            desc = "Jump to a file by its first character";
          }
          {
            on = [ "T" ];
            run = "plugin toggle-pane max-preview";
            desc = "Maximize or restore the preview pane";
          }
          {
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
            desc = "Change permissions of selected files";
          }
          {
            on = [ "C" ];
            run = "plugin ouch";
            desc = "Compress with ouch";
          }
          {
            on = [
              "R"
              "b"
            ];
            run = "plugin recycle-bin";
            desc = "Open recycle bin";
          }
          {
            on = [
              "M"
              "m"
            ];
            run = "plugin gvfs -- select-then-mount --jump";
            desc = "Select a device to mount and jump to it";
          }
          {
            on = [
              "M"
              "u"
            ];
            run = "plugin gvfs -- select-then-unmount";
            desc = "Select a device to unmount";
          }
          {
            on = [
              "M"
              "U"
            ];
            run = "plugin gvfs -- select-then-unmount --eject";
            desc = "Select a device to eject";
          }
        ];
      };
    };
}
