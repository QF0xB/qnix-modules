{ }:
{
  mkNixosFeatureImports =
    {
      category,
      name,
    }:
    [
      ../options/nixos/${category}/${name}.nix
      ../modules/nixos/${category}/${name}.nix
    ];

  mkNixosOptionImports =
    {
      category,
      name,
    }:
    [
      ../options/nixos/${category}/${name}.nix
    ];

  mkHomeFeatureImports =
    {
      category,
      name,
    }:
    [
      ../options/nixos/${category}/${name}.nix
      ../modules/home/${category}/${name}.nix
    ];

  mkHomeOptionImports =
    {
      category,
      name,
    }:
    [ ../options/nixos/${category}/${name}.nix ];
}
