{ lib, ... }:

{
  options.qnix.core.vpn = {
    enable = lib.mkEnableOption "vpn" // {
      default = false;
    };

    openvpn = {
      enable = lib.mkEnableOption "openvpn" // {
        default = true;
      };

      servers = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              # If set, use this literal OpenVPN configuration (it can reference
              # files written into /etc/openvpn/<serverName>/...).
              config = lib.mkOption {
                type = lib.types.nullOr lib.types.lines;
                default = null;
                description = ''
                  OpenVPN configuration for the server/client instance.
                  See {manpage}`openvpn(8)` for details.
                '';
              };

              # If set, use `config /etc/openvpn/<name>/<configFile>`.
              configFile = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  Path (relative to /etc/openvpn/<serverName>/) of a config file
                  to reference via OpenVPN's `config ...` directive.
                '';
              };

              # Write files referenced by your OpenVPN configuration.
              # Each entry is written to /etc/openvpn/<serverName>/<path>.
              files = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    options = {
                      # Provide either `content` or `source` (absolute path).
                      content = lib.mkOption {
                        type = lib.types.nullOr lib.types.lines;
                        default = null;
                        description = lib.mdDoc "File content (embedded into the Nix store).";
                      };

                      source = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        description = lib.mdDoc ''
                          Absolute path to an existing file on the target machine.
                          If set, NixOS will copy it into place during activation.
                        '';
                      };

                      mode = lib.mkOption {
                        type = lib.types.str;
                        default = "0444";
                        description = "POSIX mode for the file (e.g. 0400 for keys).";
                      };
                    };
                  }
                );
                default = { };
                description = ''
                  Additional files needed by OpenVPN (certs, keys, scripts, and
                  optionally config files). Those will be written by NixOS into
                  /etc/openvpn/<serverName>/...
                '';
              };

              updateResolvConf = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = lib.mdDoc ''
                  Use OpenVPN's `update-resolv-conf` script to update resolv.conf
                  with DNS information.
                '';
              };

              systemdServiceType = lib.mkOption {
                type = lib.types.enum [
                  "notify"
                  "simple"
                  "exec"
                ];
                default = "simple";
                description = lib.mdDoc ''
                  systemd unit `Type=` for `openvpn-<name>.service`.

                  NixOS' upstream OpenVPN module defaults to `Type=notify`, but
                  some OpenVPN builds/systems may not emit sd_notify, which
                  causes systemd startup timeouts. Use `simple` as a safe
                  fallback.
                '';
              };

              up = lib.mkOption {
                default = "";
                type = lib.types.lines;
                description = "Shell commands executed when the instance is starting.";
              };

              down = lib.mkOption {
                default = "";
                type = lib.types.lines;
                description = "Shell commands executed when the instance is shutting down.";
              };

              autoStart = lib.mkOption {
                default = true;
                type = lib.types.bool;
                description = "Whether this OpenVPN instance should be started automatically.";
              };

              authUserPass = lib.mkOption {
                default = null;
                description = lib.mdDoc ''
                  Store username / password credentials using OpenVPN's
                  `auth-user-pass` method.

                  WARNING: Using this option puts the credentials WORLD-READABLE in
                  the Nix store.
                '';
                type = lib.types.nullOr (
                  lib.types.submodule {
                    options = {
                      username = lib.mkOption {
                        description = lib.mdDoc "The username to store inside the credentials file.";
                        type = lib.types.str;
                      };
                      password = lib.mkOption {
                        description = lib.mdDoc "The password to store inside the credentials file.";
                        type = lib.types.str;
                      };
                    };
                  }
                );
              };

              # File-based alternative to `authUserPass` that does not embed
              # secrets into the Nix store.
              #
              # If set, the module will append `auth-user-pass <path>` at the
              # end of the generated OpenVPN config so it overrides a bare
              # `auth-user-pass` directive in the base config.
              authUserPassFile = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = lib.mdDoc ''
                  Absolute path to a credentials file to be used by OpenVPN's
                  `auth-user-pass` directive.

                  The file is expected to contain username and password in
                  the format OpenVPN accepts (typically two lines: username
                  then password).
                '';
              };
            };
          }
        );
        default = { };
        description = lib.mdDoc ''
          Define OpenVPN instances (servers or clients) that are implemented via
          NixOS `services.openvpn.servers.<name>`.
        '';
      };

    };
  };
}
