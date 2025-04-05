# User ID (UID) Allocation Policy

This system uses a fixed UID allocation strategy to ensure consistency across builds, upgrades, and networked devices. The policy improves security, prevents file ownership conflicts, and simplifies system maintenance.

## UID Allocation Table

| Username     | UID   | Description                     | Notes                              |
|--------------|-------|----------------------------------|-----------------------------------|
| `root`       | `0`   | Superuser                       | Reserved by the system             |
| `adminuser`  | `1000`| Primary system administrator    | SSH login + `sudo` privileges      |
| `normaluser` | `1001`| Default runtime user            | For general operation (Development)|
| `appuser`    | `1100`| daemon/service user             | Used by services/apps              |
| `logger`     | `1101`| Log collection & maintenance    | May run cron or journald tasks     |

## UID Ranges

| UID Range     | Purpose                          |
|---------------|----------------------------------|
| `0`           | System root user                 |
| `1 – 999`     | System/daemon users (OS reserved)|
| `1000 – 1099` | Interactive users (admin/dev)    |
| `1100 – 1999` | daemon users                     |
| `2000+`       | Reserved for runtime/dynamic use |

## Policy Guidelines

- All UIDs are **statically assigned** through Yocto recipes using `USERADD_PARAM`.
- Each user’s home directory is created with strict permissions and an SSH key-based login.
- Password logins are disabled via `-p '!'` to enforce key-only access.
- Ownership of persistent storage or bind-mounted volumes is **tied to UID**, not username.
- UID map is enforced across all device variants to ensure consistency.
