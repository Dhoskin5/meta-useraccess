SUMMARY = "Add adminuser, normaluser, appuser; and ssh key access"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit useradd ssh-keys
RDEPENDS:${PN} += "bash"

do_install[recrdeptask] += "do_prepare_ssh_keys"

#Generate a key for each user
MY_USERS = "adminuser normaluser appuser"
SSH_KEY_LABELS = "${MY_USERS}"

FILES:${PN} += "/home/*/.ssh /home/*/.ssh/authorized_keys"

USERADD_PACKAGES = "${PN}"

#Group
GROUPADD_PARAM:${PN} = "\
    adminuser; \
    normaluser; \
    -r appuser; \
"
#User
USERADD_PARAM:${PN} = "\
    -m -g adminuser -G sudo,adm -s /bin/bash -p '*' adminuser; \
    -m -g normaluser -s /bin/bash -p '*' normaluser; \
    -r -m -g appuser -s /bin/bash -p '*' appuser; \
    "

do_install:append() {
    for user in ${MY_USERS}; do
        homedir="${D}/home/${user}"
        keyfile="${SSH_KEYS_DIR}/${user}_key.pub"
        install -d -m 0700 -o ${user} -g ${user} "${homedir}/.ssh"
        install -m 0600 -o ${user} -g ${user} "${keyfile}" "${homedir}/.ssh/authorized_keys"
    done  
}
