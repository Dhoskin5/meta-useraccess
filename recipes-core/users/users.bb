SUMMARY = "Add adminuser, normaluser, appuser; and optional key access"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit useradd ssh-keys
RDEPENDS:${PN} += "bash"

SSH_USERS = "root adminuser normaluser appuser"

FILES:${PN} += " \
    /home/appuser/.ssh \
    /home/normaluser/.ssh \
    /home/adminuser/.ssh \
"

USERADD_PACKAGES = "${PN}"

GROUPADD_PARAM:${PN} = "\
    -g 1000 adminuser; \
    -g 1001 normaluser; \
    -g 1100 appuser; \
"

USERADD_PARAM:${PN} = "\
    -m -u 1000 -g adminuser -G sudo,adm -s /bin/bash -p '*' adminuser; \
    -m -u 1001 -g normaluser -s /bin/bash -p '*' normaluser; \
    -m -u 1100 -g appuser -s /bin/bash -p '*' appuser; \
    "

do_install:append() {

    install -d -m 0700 -o 1100 -g 1100 ${D}/home/appuser/.ssh
    install -m 0600 -o 1100 -g 1100 ${APPUSER_PUBKEY_PATH} ${D}/home/appuser/.ssh/authorized_keys
      
    install -d -m 0700 -o 1001 -g 1001 ${D}/home/normaluser/.ssh
    install -m 0600 -o 1001 -g 1001 ${NORMALUSER_PUBKEY_PATH} ${D}/home/normaluser/.ssh/authorized_keys
    
    install -d -m 0700 -o 1000 -g 1000 ${D}/home/adminuser/.ssh
    install -m 0600 -o 1000 -g 1000 ${ADMIN_PUBKEY_PATH} ${D}/home/adminuser/.ssh/authorized_keys   
    
    # Only install root SSH key if enabled via image feature
    if echo "${IMAGE_FEATURES}" | grep -q "ssh-root-access"; then    
        install -d -m 0700 -o 0 -g 0 ${D}/root/.ssh
        install -m 0600 -o 0 -g 0 ${ROOT_PUBKEY_PATH} ${D}/root/.ssh/authorized_keys
    else      
        bbnote "Skipping root SSH key install (ssh-root-access not in IMAGE_FEATURES)"
    fi	 
}

python __anonymous() {
    if 'ssh-root-access' in (d.getVar('IMAGE_FEATURES') or '').split():
        d.appendVar("FILES:${PN}", " /root/.ssh")
    else:
        bb.note("Not adding root authorized_keys to FILES since ssh-root-access is not enabled")
}
