FILESEXTRAPATHS_append_zaius := "${THISDIR}/${PN}:"

PCIE_CARD_INSTANCE = "phosphor-pcie-card-pe0 \
                       phosphor-pcie-card-pe1 \
                       phosphor-pcie-card-pe2 \
                       phosphor-pcie-card-pe3 \
                       phosphor-pcie-card-pe4 \
                       phosphor-pcie-card-e2a \
                       phosphor-pcie-card-e2b \
                       fan0-tach \
                       fan1-tach \
                       fan2-tach \
                       fan3-tach \
                       "

TMPL = "phosphor-gpio-presence@.service"
INSTFMT = "phosphor-gpio-presence@{0}.service"
TGT = "${SYSTEMD_DEFAULT_TARGET}"
FMT = "../${TMPL}:${TGT}.requires/${INSTFMT}"

PCIE_ENVS = "obmc/gpio/{0}.conf"
SYSTEMD_LINK_${PN}-presence_append_zaius += "${@compose_list(d, 'FMT', 'PCIE_CARD_INSTANCE')}"
SYSTEMD_ENVIRONMENT_FILE_${PN}-presence_append_zaius += "${@compose_list(d, 'PCIE_ENVS', 'PCIE_CARD_INSTANCE')}"
