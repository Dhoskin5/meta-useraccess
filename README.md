# meta-useraccess

> A portable Yocto layer for user management and secure access policies.

---

## Overview

`meta-useraccess` is a portable Yocto/OpenEmbedded layer that manages system users, SSH access, and login policies for embedded Linux systems. It provides **secure defaults**, a consistent UID policy, and clear separation between development and production access control.

This project was created to offer an easy, maintainable way to add secure user access to any Yocto-based image using a single, reusable layer.

---

## Features

- ✅ Define custom system users with static UIDs, groups, and shells
- 🔐 Disable password-based logins by default (`-p '!'`)
- 🔑 Install SSH public keys for each user at image build time
- 📁 Provide hardened `sshd_config` defaults (optional override)
- 🧪 Tested with Yocto 5.0 (Scarthgap)

---

## UID Policy

User IDs are statically assigned to avoid conflicts across devices. See [`UID_Policy.md`](./UID_Policy.md) for full details.

| Username     | UID   | Description                     | Notes                              |
|--------------|-------|----------------------------------|-----------------------------------|
| `root`       | `0`   | root                            | Reserved by the system             |
| `adminuser`  | `1000`| Primary system administrator    | SSH login + `sudo` privileges      |
| `normaluser` | `1001`| Default runtime user            | For general operation (Development)|
| `appuser`    | `1100`| daemon/service user             | Used by daemon/services            |
| `logger`     | `1101`| Log collection & maintenance    | May run cron or journald tasks     |

---

## License

[MIT License](./LICENSE)  
Copyright (c) 2025  
Dustin Hoskins
