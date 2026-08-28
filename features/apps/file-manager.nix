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
        pkgs.yazi
      ];
    };
}
