SERIAL_DEVICE_INTERFACE=/dev/ttyUSB0
CMD_DELAY="1.5"
FILENAME_EXT=''
BASE_DIR=$1

LOADER_1=loader_1st_128kb.bin
LOADER_2=loader_2nd.bin
LOADER_2_PARM=loader_2nd_param.bin
FLASH_LOADER_DIR=$pwd/files
UBOOT_FILE=u-boot.bin
UBOOT_PARM=u-boot_param.bin

# do_em_e
# $1 = partition number

do_em_e() {
	# Flash writer just looks for CR. It ignores LF characters.
	echo "Erasing Partion $1"
	echo "Sending EM_E command..."
	echo -en "EM_E\r" > $SERIAL_DEVICE_INTERFACE
	sleep $CMD_DELAY
	echo -en "$1\r" > $SERIAL_DEVICE_INTERFACE
	sleep $CMD_DELAY
}

# do_em_wb
# $1 = string
# $2 = partition number
# $3 = eMMC block address to write to
# $4 = filename
do_em_wb() {
	# Flash writer just looks for CR. It ignores LF characters.
	echo "Writting $1 ($4)"
	echo "Sending EM_WB command..."
	echo -en "EM_WB\r" > $SERIAL_DEVICE_INTERFACE
	sleep $CMD_DELAY
	echo -en "$2\r" > $SERIAL_DEVICE_INTERFACE
	sleep $CMD_DELAY
	echo -en "$3\r" > $SERIAL_DEVICE_INTERFACE
	sleep $CMD_DELAY

	# get the file size of our binary
	SIZE_DEC=$(stat -L --printf="%s" $4)
	SIZE_HEX=$(printf '%X' $SIZE_DEC)
	echo -en "$SIZE_HEX\r" > $SERIAL_DEVICE_INTERFACE
	sleep $CMD_DELAY

	echo "Sending file..."
	#cat $4 > $SERIAL_DEVICE_INTERFACE
	stat -L --printf="%s bytes\n" $4
	dd if=$4 of=$SERIAL_DEVICE_INTERFACE bs=1k status=progress
	sleep $CMD_DELAY
	echo ""
}
do_em_w() {
    echo "S-Record Write"
}
# do_emmc_write
# $1 = string
# $2 = partition number
# $3 = eMMC starting block to write
# $4 = RAM address to download to
# $5 = filename
do_emmc_write() {
	# Send a CR (\r) just to make sure there are not extra characters left over from the last transfer
	#echo -en "\r" > $SERIAL_DEVICE_INTERFACE

	# Check if file is SREC or bin
	FILENAME=$BASE_DIR/$5
	FILENAME_EXT=`echo ${FILENAME: -4}`

	if [ "$FILENAME_EXT" == ".srec" ] ; then
		# S-Record Write
		do_em_w "$1" $2 $3 $4 $5
	else
		# Binary Write
		do_em_wb "$1" $2 $3 $FILENAME
	fi
}
if [ ! -f $BASE_DIR/$LOADER_1 ]; then
    echo $BASE_DIR/$LOADER_1 Does not exist
    exit
fi
if [ ! -f $BASE_DIR/$LOADER_2_PARM ]; then
    echo $BASE_DIR/$LOADER_2_PARM Does not exist
    exit
fi
if [ ! -f $BASE_DIR/$LOADER_1 ]; then
    echo $BASE_DIR/$LOADER_1 Does not exist
    exit
fi
if [ ! -f $BASE_DIR/$LOADER_2 ]; then
    echo $BASE_DIR/$LOADER_2 Does not exist
    exit
fi

if [ ! -f $BASE_DIR/$UBOOT_PARM ]; then
    echo $BASE_DIR/$UBOOT_PARM Does not exist
    exit
fi

if [ ! -f $BASE_DIR/$UBOOT_FILE ]; then
    echo $BASE_DIR/$UBOOT_FILE Does not exist
    exit
fi
do_em_e 1
do_emmc_write "loader 1"       1 000 0 $LOADER_1
sleep 10
do_emmc_write "loader2 parms"  1 100 0 $LOADER_2_PARM
do_emmc_write "loader2 bin"    1 101 0 $LOADER_2
sleep 10
do_emmc_write "u-boot parm"    1 901 0 $UBOOT_PARM
do_emmc_write "u-boot bin"     1 902 0 $UBOOT_FILE
sleep 20

