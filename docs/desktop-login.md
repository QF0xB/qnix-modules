# Desktop login

## Automatic login with startup locking

For the Hyprland profile with integrated Home Manager, opt in on a host:

```nix
qnix.desktop.noctalia-greeter.autoLogin = {
  enable = true;
  user = "q.braendli";
};
```

greetd starts the user's Hyprland session through UWSM once at boot. Noctalia
locks the session from its startup hook, before restoring the wallpaper. Logging
out returns to the normal greeter. Autologin remains disabled by default.

The user must have an autostarted Noctalia shell with its lockscreen enabled in
integrated Home Manager. Startup locking happens after the compositor and shell
start; it does not provide an atomic, already-locked compositor startup. Remote
desktop still requires a separately configured server.

For startup locking without autologin, set
`qnix.desktop.noctalia.lockOnStartup = true` in the user's Home Manager config.

## Password or YubiKey

`qnix.security.yubikey.login = true` enables the enrolled YubiKey as an
alternative to the account password for console login, Noctalia's greeter and
lockscreen, and SDDM. `qnix.security.yubikey.sudo = true` does the same for sudo.

Password authentication runs first. A correct password succeeds without a
YubiKey. To use the key instead, submit an empty password and touch the enrolled
key when prompted. Integrated Noctalia sessions allow empty submissions when
YubiKey login is enabled. An empty password alone never authenticates an account
with a nonempty password. Missing or failed keys still require a valid password.

## Keyring unlock

The `security.gnome-keyring` feature adds GNOME Keyring PAM support to `login`
and SDDM. greetd includes the `login` stack, and Noctalia uses it for screen
unlock. Password authentication reaches GNOME Keyring before completing login.

The login keyring password must match the account password. Use Seahorse to
change an existing keyring password if they differ. Enable
`qnix.security.gnome-keyring.gui = true` to install Seahorse.

Autologin and YubiKey-only authentication supply no account password, so they
cannot decrypt a password-protected keyring. Enter the matching password at the
Noctalia lockscreen to unlock it after autologin. A separate keyring prompt may
still appear when the keyring password differs.
