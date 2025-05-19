> A portable Yocto layer for secure user management, SSH key provisioning, and dynamic UID policies.

---

## Overview

`meta-useraccess` is a reusable Yocto/OpenEmbedded layer for defining system users, enforcing secure login defaults, and generating SSH keypairs at build time.

It was created to provide a single, maintainable way to implement secure access control across embedded devices. The layer supports production-grade SSH policies, build-time key provisioning, and safe UID handling that avoids collisions with system services and container runtimes.

---

## Features

- Define system users with flexible group memberships and login shells
- Disable password-based login by default (`-p '*'`)
- Generate SSH keypairs at build time using abstract labels (not just usernames)
- Public keys are installed to authorized locations in the image
- Optional recipe for root-only SSH access
- Tested with Yocto 5.0 (Scarthgap)

---

## SSH Configuration Behavior

The layer installs an `sshd_config` file appropriate to the image type:

- **Development images** (default): root login and password authentication are allowed for convenience.
- **Production images** install a hardened configuration:
  - Only key-based login is allowed
  - `adminuser` and `normaluser` are the only users permitted SSH access
  - `root` login is explicitly disabled

To enable production mode, set the following in your image recipe or `local.conf`:

```bitbake
PRODUCTION_IMAGE = "1"
```

---

## Getting Started

### 1. Add the layer to your build:

```bash
bitbake-layers add-layer meta-useraccess
```

### 2. Configure SSH key labels in `local.conf` or your image recipe:

```ini
SSH_KEYS_DIR = "${TOPDIR}/generated-keys"
```

The directory will be created at build time. Keys will only be generated if they don’t already exist.

---

## Included Recipes

| Recipe                      | Purpose                                             |
|----------------------------|-----------------------------------------------------|
| `users.bb`                 | Adds `adminuser`, `normaluser`, and `appuser`       |
| `root-ssh-key.bb`          | Installs SSH key for root (optional)                |
| `openssh_%.bbappend`       | Installs dev or prod `sshd_config` as appropriate   |
| `ssh-keys.bbclass`         | Generates SSH keypairs from labels (abstract/flexible) |

---

## UID Policy

By default, user IDs are **dynamically assigned** by the build system to avoid UID collisions with container runtimes and OS services.

This improves compatibility with Podman, systemd-journald, and other packages that create users at build or runtime.

You may optionally assign fixed UIDs in your `local.conf` or image configuration:

```bitbake
MY_FIXED_UID_adminuser = "1050"
MY_FIXED_UID_normaluser = "1051"
```

You would then update your user creation logic to apply these variables.

### Expected UID Ranges (Typical)

| Username     | Approx UID Range | Notes                              |
|--------------|------------------|-----------------------------------|
| `adminuser`  | ≥1000            | Interactive login, has sudo       |
| `normaluser` | ≥1001            | General use, login allowed        |
| `appuser`    | <1000 (e.g. 994) | System account, no login          |

---

## Compatibility

```ini
LAYERSERIES_COMPAT_useraccess = "scarthgap"
```

Tested on:
- Yocto 5.0 (Scarthgap)
- QEMU AArch64 targets
- Rockchip platforms

---

## License

[MIT License](./LICENSE)
© 2025 Dustin Hoskins
