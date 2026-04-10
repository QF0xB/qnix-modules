{ lib }:
{
  status = {
    headless = lib.mkDefault true;
    server = lib.mkDefault true;
  };
}
