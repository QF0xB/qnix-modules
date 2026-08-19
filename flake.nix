{
  description = "QNix reusable feature modules";

  inputs.qnix-sdk.url = "github:QF0xB/qnix-sdk";

  outputs = {qnix-sdk, ...}: {
    lib.mkQNix = {
      namespace ? "qnix",
      context ? {},
    }: let
      sdk = qnix-sdk.lib.mkSdk {
        inherit namespace context;
      };
    in
      sdk.mkRepository {
        features = ./features;
        profiles = ./profiles;
      };
  };
}
