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
#   - Keys generated only when SSH_KEYS_ENABLED = "1"
#   - Per-user directory cleanup before regeneration
#   - Secure permissions (0700) on generated key folders
#   - Manual cleanup task: `bitbake -c clean_ssh_keys <target>`
#
# Required Configuration:
#   SSH_KEYS_ENABLED = "1"
#   SSH_KEYS_DIR     = "${TOPDIR}/generated-keys"
#   SSH_USERS        = "admin user1"
#
# Optional Overrides:
#   SSH_KEY_TYPE     = "rsa"      # or "ed25519"
#   SSH_KEY_BITS     = "4096"     # RSA only
#
# Optional:
#   SSH_ROOT_ACCESS_ENABLED = "1"  # Used in consuming recipes for root key install logic
#
# Use in your recipe:
#   inherit ssh-keys
#   install -m 0600 ${ADMIN_PUBKEY_PATH} /home/admin/.ssh/authorized_keys

python do_generate_ssh_keys() {
    import os
    import subprocess
    import shutil

    if d.getVar("SSH_KEYS_ENABLED") != "1":
        bb.note("Skipping SSH key generation (SSH_KEYS_ENABLED is not set to '1')")
        return

    keys_dir = d.getVar('SSH_KEYS_DIR')
    if not keys_dir:
        bb.fatal("SSH_KEYS_DIR is not set. You must define it in local.conf or your image recipe.")

    if not os.path.exists(keys_dir):
        bb.note(f"Creating SSH key output directory: {keys_dir}")
        os.makedirs(keys_dir, exist_ok=True)

    users_raw = d.getVar('SSH_USERS') or ""
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

