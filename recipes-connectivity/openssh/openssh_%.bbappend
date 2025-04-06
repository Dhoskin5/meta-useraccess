FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit systemd

SYSTEMD_SERVICE:${PN} = "sshd.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

SRC_URI:append = " \
    file://sshd_config.dev \
    file://sshd_config.prod \
"

do_install:append() {
        install -m 0600 ${WORKDIR}/sshd_config.dev ${D}${sysconfdir}/ssh/sshd_config
}
