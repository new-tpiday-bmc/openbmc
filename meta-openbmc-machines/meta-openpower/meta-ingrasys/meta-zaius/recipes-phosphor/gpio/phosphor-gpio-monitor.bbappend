FILESEXTRAPATHS_append_zaius := "${THISDIR}/${PN}:"

PCIE_CARD_INSTANCE = "pe0 \
                       pe1 \
                       pe2 \
                       pe3 \
                       pe4 \
                       e2a \
                       e2b \
                       "

TMPL = "phosphor-gpio-presence@.service"
INSTFMT = "phosphor-gpio-presence@{0}.service"
TGT = "${SYSTEMD_DEFAULT_TARGET}"
FMT = "../${TMPL}:${TGT}.requires/${INSTFMT}"

PCIE_ENVS = "obmc/gpio/phosphor-pcie-card-{0}.conf"
SYSTEMD_LINK_${PN}-presence_append_zaius += "${@compose_list(d, 'FMT', 'PCIE_CARD_INSTANCE')}"
SYSTEMD_ENVIRONMENT_FILE_${PN}-presence_append_zaius += "${@compose_list(d, 'PCIE_ENVS', 'PCIE_CARD_INSTANCE')}"
