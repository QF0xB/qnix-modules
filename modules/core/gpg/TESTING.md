# GPG Module Testing Guide

This guide helps you test the GPG module with SSH agent support and YubiKey integration.

## Prerequisites

1. Ensure both GPG and YubiKey modules are enabled in your `qnix.nix`:
   ```nix
   qnix.core.gpg.enable = true;
   qnix.core.yubikey.enable = true;  # If using YubiKey
   ```

2. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch --flake .#YourHost
   ```

## Testing Basic GPG Functionality

### 1. Check GPG Installation
```bash
gpg --version
```

### 2. Check GPG Agent Status
```bash
gpg-agent --version
gpgconf --list-dirs
```

### 3. Verify SSH Agent Socket
```bash
echo $SSH_AUTH_SOCK
# Should output: /run/user/<uid>/gnupg/S.gpg-agent.ssh

# Or check if socket exists
ls -la $XDG_RUNTIME_DIR/gnupg/
```

### 4. Test GPG Agent
```bash
# Restart GPG agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Check agent is running
gpg-connect-agent /bye
```

## Testing Public Key Import

### Option 1: Import from String (for testing)
Add to your `qnix.nix`:
```nix
qnix.core.gpg = {
  enable = true;
  publicKeys = [
    ''
      -----BEGIN PGP PUBLIC KEY BLOCK-----
      [Your public key here]
      -----END PGP PUBLIC KEY BLOCK-----
    ''
  ];
};
```

### Option 2: Import from File
```nix
qnix.core.gpg = {
  enable = true;
  publicKeys = [
    ./path/to/public-key.asc
  ];
};
```

### Option 3: Import Test Key (for verification)
You can use a well-known key for testing:
```nix
qnix.core.gpg = {
  enable = true;
  publicKeys = [
    # Example: Linus Torvalds' key (for testing only)
    "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x79BE3E4300411886"
  ];
};
```

### Verify Imported Keys
After rebuilding:
```bash
# List all public keys
gpg --list-keys

# List keys with details
gpg --list-keys --keyid-format LONG

# Check specific key
gpg --fingerprint <key-id>
```

## Testing YubiKey Integration

### 1. Check YubiKey Detection
```bash
# Check if YubiKey is detected
gpg --card-status

# Should show YubiKey information if connected
```

### 2. Check PC/SC Daemon
```bash
# Check if pcscd is running
systemctl status pcscd

# Test smartcard reader
pcsc_scan
```

### 3. Test Smartcard Operations
```bash
# List keys on smartcard
gpg --card-status

# If you have keys on YubiKey, test signing
echo "test" | gpg --clearsign

# Test authentication key (for SSH)
gpg --list-keys --with-keygrip
```

## Testing SSH Agent Functionality

### 1. Check SSH Agent Socket
```bash
# Verify SSH_AUTH_SOCK is set correctly
echo $SSH_AUTH_SOCK
# Should be: /run/user/<uid>/gnupg/S.gpg-agent.ssh

# Test SSH agent connection
ssh-add -l
```

### 2. Export SSH Public Key from GPG
If you have an authentication subkey on your GPG key (or YubiKey):
```bash
# Export SSH public key from GPG authentication key
gpg --export-ssh-key <key-id>

# Or if using YubiKey with authentication key
gpg --export-ssh-key $(gpg --list-keys --with-colons | grep "^fpr" | cut -d: -f10 | head -1)
```

### 3. Test SSH Connection
```bash
# Add your SSH public key to remote server
ssh-copy-id -i <(gpg --export-ssh-key <key-id>) user@host

# Test SSH connection (will prompt for YubiKey PIN if using smartcard)
ssh user@host
```

## Testing Pinentry

### 1. Test Different Pinentry Flavors
Change `pinentryFlavor` in your config:
```nix
qnix.core.gpg = {
  enable = true;
  pinentryFlavor = "qt";  # or "gtk2", "curses", "gnome3"
};
```

### 2. Test Pinentry Prompt
```bash
# Trigger a GPG operation that requires PIN entry
gpg --sign --detach-sig /etc/passwd  # Will prompt for PIN

# Or test with YubiKey
gpg --card-edit
# Then type: admin
# Then type: passwd
```

## Troubleshooting

### GPG Agent Not Starting
```bash
# Kill existing agent
gpgconf --kill gpg-agent

# Start manually to see errors
gpg-agent --daemon --verbose

# Check logs
journalctl --user -u gpg-agent
```

### YubiKey Not Detected
```bash
# Check udev rules
lsusb | grep -i yubico

# Check pcscd
systemctl status pcscd
sudo systemctl restart pcscd

# Test with ykman (if installed)
ykman info
```

### SSH Agent Not Working
```bash
# Verify socket exists
ls -la $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh

# Test connection
gpg-connect-agent 'getinfo socket_name' /bye

# Restart agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

### Public Keys Not Imported
```bash
# Check Home Manager activation logs
home-manager switch --debug

# Manually import to test
gpg --import <key-file>

# Check if keys are in keyring
gpg --list-keys
```

## Quick Test Script

Create a test script to verify everything works:

```bash
#!/bin/bash
set -e

echo "Testing GPG Module..."

echo "1. Checking GPG version..."
gpg --version

echo "2. Checking GPG agent..."
gpg-connect-agent /bye

echo "3. Checking SSH agent socket..."
if [ -S "$SSH_AUTH_SOCK" ]; then
  echo "✓ SSH agent socket exists: $SSH_AUTH_SOCK"
else
  echo "✗ SSH agent socket not found"
  exit 1
fi

echo "4. Checking YubiKey (if enabled)..."
if gpg --card-status > /dev/null 2>&1; then
  echo "✓ YubiKey detected"
  gpg --card-status
else
  echo "⚠ YubiKey not detected (may not be connected)"
fi

echo "5. Listing GPG keys..."
gpg --list-keys

echo "6. Testing SSH agent..."
ssh-add -l || echo "⚠ No SSH keys in agent"

echo "✓ All tests completed!"
```

Save as `test-gpg.sh`, make executable, and run:
```bash
chmod +x test-gpg.sh
./test-gpg.sh
```
