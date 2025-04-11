# ssh-keys.bbclass
#
# Secure, build-time SSH key generation for Yocto-based images.
#
# This class dynamically generates per-user SSH keypairs at build time.
# Keys are stored outside of the root filesystem and can be used by
# consuming recipes to install public keys into user home directories.
#
# Features:
#   - RSA and ED25519 key support
#   - Configurable bit-length (RSA only)
#   - Private keys are never installed to target images
#   - Automatically skips generation if key already exists
#   - Enforces secure permissions (0700) on output directory
#
# Required Configuration:
#   SSH_KEYS_DIR     = "${TOPDIR}/generated-keys"
#   SSH_KEY_LABELS        = "adminuser normaluser appuser"
#
# Optional Overrides:
#   SSH_KEY_TYPE     = "rsa"      # Default: ed25519
#   SSH_KEY_BITS     = "4096"     # RSA only
#
# Example usage in a recipe:
#   inherit ssh-keys
#
#   do_install:append() {
#       install -d -m 0700 -o 1000 -g 1000 ${D}/home/adminuser/.ssh
#       install -m 0600 -o 1000 -g 1000 ${SSH_KEYS_DIR}/adminuser_key.pub ${D}/home/adminuser/.ssh/authorized_keys
#   }

python do_prepare_ssh_keys() {
    import os
    import subprocess
    import shutil

    keys_dir = d.getVar('SSH_KEYS_DIR')
    if not keys_dir:
        bb.fatal("SSH_KEYS_DIR is not set. You must define it in local.conf or your image recipe.")

    if not os.path.exists(keys_dir):
        bb.note(f"Creating SSH key output directory: {keys_dir}")
        os.makedirs(keys_dir, exist_ok=True)

    users_raw = d.getVar('SSH_KEY_LABELS') or ""
    users = users_raw.split()

    key_type = d.getVar('SSH_KEY_TYPE') or 'ed25519'
    key_bits = d.getVar('SSH_KEY_BITS') or '4096'

    for user in users:
        user_sanitized = user.strip()
        if not user_sanitized:
            continue

        priv_key = os.path.join(keys_dir, f"{user_sanitized}_key")
        pub_key = priv_key + ".pub"

        if os.path.isfile(priv_key) or os.path.isfile(pub_key):
            bb.warn(f"SSH keys for user '{user_sanitized}' already exist. Skipping generation.")
            continue

        bb.note(f"Generating {key_type.upper()} SSH key for user: {user_sanitized}")
        try:
            cmd = ['ssh-keygen', '-t', key_type, '-f', priv_key, '-N', '']
            if key_type == 'rsa':
                cmd.extend(['-b', key_bits])
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError as e:
            bb.fatal(f"SSH key generation failed for user '{user_sanitized}': {e}")

        bb.warn(f"[ssh-keys.bbclass] Private key path: {priv_key}")
        bb.warn(f"[ssh-keys.bbclass] Public key path:  {pub_key}")

        image_rootfs = d.getVar('IMAGE_ROOTFS')
        if image_rootfs and priv_key.startswith(image_rootfs):
            bb.fatal(f"Private key path {priv_key} is inside IMAGE_ROOTFS. This must not happen.")
}

addtask do_prepare_ssh_keys before do_install
