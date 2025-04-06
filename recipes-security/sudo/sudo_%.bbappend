FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


SRC_URI:append = " \
	file://sudoers_adminuser \
	"

do_install:append() {
      install -m 0440 ${WORKDIR}/sudoers_adminuser ${D}${sysconfdir}/sudoers.d/adminuser 
} 

