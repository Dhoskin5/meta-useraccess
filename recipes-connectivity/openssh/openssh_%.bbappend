FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit systemd

SYSTEMD_SERVICE:${PN} = "sshd.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

SRC_URI:append = " \
    file://sshd_config.dev \
    file://sshd_config.prod \
"

do_install:append() {
    if [ "${PRODUCTION_IMAGE}" = "1" ]; then
        install -m 0600 ${WORKDIR}/sshd_config.prod ${D}${sysconfdir}/ssh/sshd_config
    else
        bbwarn "meta-useraccess: Installing development sshd_config — not suitable for production use"
        install -m 0600 ${WORKDIR}/sshd_config.dev ${D}${sysconfdir}/ssh/sshd_config
    fi
}
