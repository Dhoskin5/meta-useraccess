SUMMARY = "Installs authorized_keys file for root"
DESCRIPTION = "Installs a build-time generated SSH public key for the root user using the ssh-keys class."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit ssh-keys

SSH_KEY_LABELS = "root"

RDEPENDS:${PN} = "openssh"

do_install() {
    install -d -m 0700 -o 0 -g 0 ${D}/root/.ssh
    install -m 0600 -o 0 -g 0 ${SSH_KEYS_DIR}/root_key.pub ${D}/root/.ssh/authorized_keys
}

FILES:${PN} += " \
    /root/.ssh \
    /root/.ssh/authorized_keys \
"
