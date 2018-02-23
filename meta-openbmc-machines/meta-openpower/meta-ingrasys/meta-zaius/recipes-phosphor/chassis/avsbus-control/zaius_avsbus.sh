#!/bin/sh -e
# AVSBus control for PMBUS voltage regulator modules (VRMs)
# Switches output voltage target between
# - VOUT_COMMAND register (AVSBus disabled, default on Zaius)
# - AVSBus target output (AVSBus enabled, voltage set by host)

cpu0_i2c_bus="7"
cpu1_i2c_bus="8"
vdd_i2c_addr_page="0x60:0x00"
vdn_i2c_addr_page="0x62:0x00"
vcs_i2c_addr_page="0x62:0x01"
vdd1_i2c_addr_page="0x61:0x00"
vdn1_i2c_addr_page="0x63:0x00"
vcs1_i2c_addr_page="0x63:0x01"
addrs_pages="$vdd_i2c_addr_page $vdn_i2c_addr_page $vcs_i2c_addr_page"
addrs_pages1="$vdd1_i2c_addr_page $vdn1_i2c_addr_page $vcs1_i2c_addr_page"

# Usage: vrm_set_page <bus> <i2c_address> <page>
vrm_set_page()
{
    i2cset -y $1 $2 0x00 $3 b
}

# Usage: vrm_avs_enable <bus> <i2c_address> <page>
# Initializes the AVSBus VOUT setpoint to the value in PMBus VOUT_COMMAND
# Sets OPERATION PMBUS register to
# - Enable/Disable: On
# - VOUT Source: AVSBus Target Rail Voltage
# - AVSBus Copy: VOUT_COMMAND remains unchanged
# Writes to VOUT setpoint over AVSBus will persist after the VRM is switched to
# PMBus control. Switching back to AVSBus control restores this persisted
# setpoint rather than re-initializing to PMBus VOUT_COMMAND. This behavior is
# known to Intersil and writing VOUT_COMMAND over PMBus is the only workaround.
vrm_avs_enable()
{
    vrm_set_page "$@"
    echo Enabling AVSBus on bus $1 VRM @$2 rail $3...
    local vout_command=`i2cget -y $1 $2 0x21 w`
    i2cset -y $1 $2 0x21 $vout_command w
    i2cset -y $1 $2 0x01 0xb0 b
}

# Usage: vrm_avs_disable <bus> <i2c_address> <page>
# Sets OPERATION PMBUS register to
# - Enable/Disable: On
# - VOUT Source: VOUT_COMMAND
# - AVSBus Copy: VOUT_COMMAND remains unchanged
vrm_avs_disable()
{
    vrm_set_page "$@"
    echo Disabling AVSBus on bus $1 VRM @$2 rail $3...
    i2cset -y $1 $2 0x01 0x80 b
}

# Usage: vrm_print <bus> <i2c_address> <page>
vrm_print()
{
    vrm_set_page "$@"
    local operation=`i2cget -y $1 $2 0x01 b`
    local vout=`i2cget -y $1 $2 0x8b w`
    local iout=`i2cget -y $1 $2 0x8c w`
    echo VRM on bus $1 @$2 rail $3: OPERATION=$operation VOUT=$vout IOUT=$iout
}

# Usage: for_each_rail <command>
# <command> will be invoked with <bus> <i2c_address> <page>
for_each_rail()
{
    for bus in $cpu0_i2c_bus
    do
        for addr_page in $addrs_pages
        do
            $1 $bus `echo $addr_page | tr : " "`
        done
    done

    for bus in $cpu1_i2c_bus
    do
        for addr_page in $addrs_pages1
        do
            $1 $bus `echo $addr_page | tr : " "`
        done
    done
}

if [ "$1" == "enable" ]
then
    for_each_rail vrm_avs_enable
elif [ "$1" == "disable" ]
then
    for_each_rail vrm_avs_disable
else
    for_each_rail vrm_print
    echo "\"$0 <enable|disable>\" to control whether VRMs use AVSBus"
fi
