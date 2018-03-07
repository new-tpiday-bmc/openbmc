FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

ZAIUS_CHIPS = "i2c@1e78a000/i2c-bus@40/ucd90160@64 \
                i2c@1e78a000/i2c-bus@40/lm75@4a \
                i2c@1e78a000/i2c-bus@40/lm75@49 \
                "

ZAIUS_ITEMSFMT = "ahb/apb/{0}.conf"

ZAIUS_ITEMS = "${@compose_list(d, 'ZAIUS_ITEMSFMT', 'ZAIUS_CHIPS')}"

ZAIUS_OCCS = " \
              sbefifo@2400/occ@1/occ-hwmon@1 \
              hub@3400/cfam@1,0/sbefifo@2400/occ@2/occ-hwmon@2 \
              "
ZAIUS_OCCSFMT = "gpio-fsi/cfam@0,0/{0}.conf"
ZAIUS_OCCITEMS = "${@compose_list(d, 'ZAIUS_OCCSFMT', 'ZAIUS_OCCS')}"

ITEMS = "iio-hwmon.conf \
         pwm-tach-controller@1e78a000.conf \
        "

ENVS = "obmc/hwmon/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN} += "${@compose_list(d, 'ENVS', 'ZAIUS_ITEMS')}"
SYSTEMD_ENVIRONMENT_FILE_${PN} += "${@compose_list(d, 'ENVS', 'ZAIUS_OCCITEMS')}"
SYSTEMD_ENVIRONMENT_FILE_${PN} += " ${@compose_list(d, 'ENVS', 'ITEMS')}"
