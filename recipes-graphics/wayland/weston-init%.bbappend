FILESEXTRAPATHS_prepend := "${THISDIR}/weston-init:"
SRC_URI += "file://0001-weston-init-support-system-s-configuration-file.patch;striplevel=5"
SRC_URI += "file://weston"
SRC_URI += "file://weston.ini"
SRC_URI += "file://weston.sh"

S = "${WORKDIR}"

do_install_append() {
        install -d ${D}/${sysconfdir}/default
        install -m755 ${WORKDIR}/weston ${D}/${sysconfdir}/default/weston

        install -d ${D}/${sysconfdir}/profile.d/
        install -m755 ${WORKDIR}/weston.sh ${D}/${sysconfdir}/profile.d/

        install -d ${D}/${sysconfdir}/xdg/weston/
        install -m755 ${WORKDIR}/weston.ini ${D}/${sysconfdir}/xdg/weston/
}
