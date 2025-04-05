SUMMARY = "System-wide SSH hardening configuration"
LICENSE = "MIT"
SRC_URI = "file://sshd_config"

FILES:${PN} += "/etc/ssh/sshd_config"

do_install() {
    install -d ${D}${sysconfdir}/ssh
    install -m 0600 ${WORKDIR}/sshd_config ${D}${sysconfdir}/ssh/sshd_config
}

