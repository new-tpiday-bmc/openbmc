SUMMARY = "Fan policy for Zaius"
PR = "r1"

inherit native
inherit obmc-phosphor-license
inherit phosphor-dbus-monitor

SRC_URI += "file://fan-errors.yaml"

do_install() {
        install -D ${WORKDIR}/fan-errors.yaml ${D}${config_dir}/fan-errors.yaml
}
