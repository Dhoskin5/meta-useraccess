# User ID (UID) Allocation Policy

**Note**: As of May 2025, static UID assignment has been removed by default to improve compatibility with Podman, systemd, and other components that manage users. UIDs are now dynamically assigned unless explicitly overridden.

---

## Current Policy

User IDs are **dynamically assigned** at build time by default. This reduces the chance of UID collisions with other system components or container runtimes.

You may still optionally assign fixed UIDs in your build configuration:

```bitbake
MY_FIXED_UID_adminuser = "1050"
MY_FIXED_UID_normaluser = "1051"
```

You must update your `USERADD_PARAM` accordingly to reference these if desired.

---

## Expected UID Ranges (Typical)

| Username     | Approx UID Range | Description                     |
|--------------|------------------|----------------------------------|
| `adminuser`  | ≥1000            | Primary system administrator     |
| `normaluser` | ≥1001            | General-purpose login user       |
| `appuser`    | <1000 (e.g. 994) | Daemon or service-only user      |

---

## Rationale

- Dynamic UIDs allow coexistence with other system users defined by external recipes (e.g. journald, Podman)
- Static UIDs can still be enforced in controlled environments
- Avoids patching conflicts across layers or during Yocto upgrades

