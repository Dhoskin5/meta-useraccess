
> A portable Yocto layer for secure user management, static UID policies, and abstract SSH key generation.

---

## Overview

`meta-useraccess` is a reusable Yocto/OpenEmbedded layer for defining system users, enforcing secure login defaults, and generating SSH keypairs at build time.

It was created to provide a single, maintainable way to implement secure access control across embedded devices. The layer supports production-grade SSH policies, build-time key provisioning, and UID consistency across system variants.

---

## Features

- Define system users with static UIDs, shells, and group assignments
-  Disable password-based login by default (`-p '*'`)
-  Generate SSH keypairs at build time using abstract labels (not just users)
-  Public keys are installed to authorized locations in the image
-  Optional recipe for root-only SSH access
-  Tested with Yocto 5.0 (Scarthgap)

---

## Getting Started

### 1. Add the layer to your build:

```bash
bitbake-layers add-layer meta-useraccess
```

### 2. Configure SSH key labels in `local.conf` or Image:

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
| `openssh_%.bbappend`       | Installs dev `sshd_config` (can be customized)      |
| `ssh-keys.bbclass`         | Generates SSH keypairs from labels (abstract/flexible) |

---

## UID Policy

User IDs are statically assigned for consistency across devices. See [`UID_Policy.md`](./UID_Policy.md) for full details.

| Username     | UID   | Description                     | Notes                              |
|--------------|-------|----------------------------------|-----------------------------------|
| `root`       | `0`   | Superuser                       | Reserved by the system             |
| `adminuser`  | `1000`| Primary system administrator    | SSH login + `sudo` privileges      |
| `normaluser` | `1001`| Default runtime user            | For general operation (Development)|
| `appuser`    | `1100`| Daemon/service user             | Used by background services        |

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