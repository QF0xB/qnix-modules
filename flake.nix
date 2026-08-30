{
  description = "QNix reusable feature modules";

  inputs = {
    qnix-sdk.url = "github:QF0xB/qnix-sdk";
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
    };
  };

  outputs =
    {
      qnix-sdk,
      mcp-servers-nix ? null,
      ...
    }:
    {
      lib.mkQNix =
        {
          namespace ? "qnix",
          context ? { },
        }:
        let
          sdk = qnix-sdk.lib.mkSdk {
            inherit namespace;
            context = if mcp-servers-nix == null then context else context // { inherit mcp-servers-nix; };
          };
        in
        sdk.mkRepository {
          features = ./features;
          profiles = ./profiles;
        };
    };
}
