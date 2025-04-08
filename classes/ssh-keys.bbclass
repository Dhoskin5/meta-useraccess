# ssh-keys.bbclass
#
# Secure, build-time SSH key generation for Yocto-based images.
#
# This class dynamically generates per-user SSH keypairs at build time,
# providing public key paths to recipes via BitBake variables.
#
# Features:
#   - RSA and ED25519 key support
#   - Configurable bit-length (for RSA)
#   - Private keys never included in image rootfs
#   - Keys generated only when 'ssh-keys' is in IMAGE_FEATURES
#   - Per-user directory cleanup before regeneration
#   - Secure permissions (0700) on generated key folders
#   - Manual cleanup task: `bitbake -c clean_ssh_keys <target>`
#
# Required Configuration:
#   SSH_KEYS_DIR    = "${TOPDIR}/generated-keys"
#   SSH_USERS       = "admin user1"
#
# Optional Overrides:
#   SSH_KEY_TYPE    = "rsa"      # or "ed25519"
#   SSH_KEY_BITS    = "4096"     # RSA only
#
# Enable in your image:
#   IMAGE_FEATURES += "ssh-keys"
#
# Use in your recipe:
#   inherit ssh-keys
#   install -m 0600 ${ADMIN_PUBKEY_PATH} /home/admin/.ssh/authorized_keys

python do_generate_ssh_keys() {
    import os
    import subprocess
    import shutil

    image_features = d.getVar('IMAGE_FEATURES') or ""
    if 'ssh-keys' not in image_features.split():
        bb.note("Skipping SSH key generation (ssh-keys not in IMAGE_FEATURES)")
        return

    keys_dir = d.getVar('SSH_KEYS_DIR')
    if not keys_dir:
        bb.fatal("SSH_KEYS_DIR is not set. You must define it in local.conf or your image recipe.")

    users_raw = d.getVar('SSH_USERS') or ""
    users = users_raw.split()

    key_type = d.getVar('SSH_KEY_TYPE') or 'rsa'
    key_bits = d.getVar('SSH_KEY_BITS') or '4096'

    for user in users:
        user_sanitized = user.strip()
        if not user_sanitized:
            continue

        user_dir = os.path.join(keys_dir, user_sanitized)

        if os.path.exists(user_dir):
            bb.note(f"Removing existing key directory for user: {user_sanitized}")
            shutil.rmtree(user_dir)

        os.makedirs(user_dir, mode=0o700, exist_ok=True)

        priv_key = os.path.join(user_dir, 'id_' + key_type)
        pub_key = priv_key + '.pub'

        bb.note(f"Generating {key_type.upper()} SSH key for user: {user_sanitized}")
        try:
            cmd = ['ssh-keygen', '-t', key_type, '-f', priv_key, '-N', '']
            if key_type == 'rsa':
                cmd.extend(['-b', key_bits])
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError as e:
            bb.fatal(f"SSH key generation failed for user '{user_sanitized}': {e}")

        key_var = f"{user.upper()}_PUBKEY_PATH"
        d.setVar(key_var, pub_key)

        image_rootfs = d.getVar('IMAGE_ROOTFS')
        if image_rootfs and priv_key.startswith(image_rootfs):
            bb.fatal(f"Private key path {priv_key} is inside IMAGE_ROOTFS. This must not happen.")
}

addtask do_generate_ssh_keys before do_install

python do_clean_ssh_keys() {
    import os
    import shutil

    keys_dir = d.getVar('SSH_KEYS_DIR')
    if not keys_dir:
        bb.warn("SSH_KEYS_DIR not set. Skipping cleanup.")
        return

    if os.path.exists(keys_dir):
        bb.note(f"Removing all generated SSH keys from: {keys_dir}")
        shutil.rmtree(keys_dir)
    else:
        bb.note(f"No SSH key directory found to clean at: {keys_dir}")
}

addtask do_clean_ssh_keys

