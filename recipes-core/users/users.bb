
SUMMARY = "Add root, adminuser, and normaluser"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "\
    file://id_ed25519_admin.pub \
    file://id_ed25519_user.pub \
    file://id_ed25519_root.pub \
    file://id_ed25519_app.pub \
    "
inherit useradd

USERADD_PACKAGES = "${PN}"
RDEPENDS:${PN}+= " bash"
USERADD_PARAM:${PN} = "\
    -m -u 1000 -G sudo,adm -s /bin/bash -p '*' adminuser; \
    -m -u 1001 -s /bin/bash -p '*' normaluser; \
    -m -u 1100 -s /bin/bash -p '*' appuser; \
    "

do_install:append() {

    install -d 700 ${D}/home/appuser/.ssh
    install -m 600 ${WORKDIR}/id_ed25519_app.pub ${D}/home/appuser/.ssh/authorized_keys
    chown -R 1100:1100 ${D}/home/appuser
    
    install -d 700 ${D}/home/adminuser/.ssh
    install -m 600 ${WORKDIR}/id_ed25519_admin.pub ${D}/home/adminuser/.ssh/authorized_keys
    chown -R 1000:1000 ${D}/home/adminuser
    
    install -d 700 ${D}/home/normaluser/.ssh
    install -m 600 ${WORKDIR}/id_ed25519_user.pub ${D}/home/normaluser/.ssh/authorized_keys
    chown -R 1001:1001 ${D}/home/normaluser
    
    install -d 700 ${D}/root/.ssh
    install -m 600 ${WORKDIR}/id_ed25519_root.pub ${D}/root/.ssh/authorized_keys       
}

FILES:${PN} += " \
    /home/adminuser/.ssh/authorized_keys \
    /home/normaluser/.ssh/authorized_keys \
    /root/.ssh/authorized_keys \
    /home/appuser/.ssh/authorized_keys \
"
