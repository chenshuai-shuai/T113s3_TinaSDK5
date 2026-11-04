#!/bin/sh
#
# Start the preinit
#

add_preinit_to_inittab(){
	if [ -e ${TARGET_DIR}/etc/inittab ]; then
		#insert preinit
		grep "::sysinit:/etc/preinit" ${TARGET_DIR}/etc/inittab >/dev/null
		if [ $? -eq 0 ]; then
			echo "preinit is already in inittab!"
		else
			echo "preinit is not in inittab, add it!"
			sed -i '/Startup the system/a ::sysinit:/etc/preinit' ${TARGET_DIR}/etc/inittab
		fi

		local getty_enable=$(grep "BR2_TARGET_GENERIC_GETTY=y" ${BR2_CONFIG})
		echo "getty_enable:${getty_enable}"
		if [ x"${getty_enable}" != x"" ]; then
			echo "getty is already commented by package/sysvinit"
			echo "tips: BR2_TARGET_GENERIC_GETTY_PORT should be console"
			sed -i '/::respawn:-\/bin\/sh/d' ${TARGET_DIR}/etc/inittab
			return 0
		fi

		echo "BR2_TARGET_GENERIC_GETTY is not set"
		#base strings maybe:console::respawn:/sbin/getty -L  console 115200 vt100 # GENERIC_SERIAL
		#getty not enable, delete unuse strings:console::respawn:/sbin/getty -L  console 115200 vt100
		sed -i "s/.*\(# GENERIC_SERIAL\)/\1/" ${TARGET_DIR}/etc/inittab

		#commented ttyS0, insert /bin/sh
		grep "#ttyS0::respawn:" ${TARGET_DIR}/etc/inittab >/dev/null
		if [ $? -eq 0 ]; then
			echo "ttyS0 is already commented!"
		else
			echo "ttyS0 is not commented, commented it!"
			sed -i 's/ttyS0/#&/' ${TARGET_DIR}/etc/inittab

			grep "::respawn:-/bin/sh" ${TARGET_DIR}/etc/inittab >/dev/null
			if [ $? -eq 0 ]; then
				echo "/bin/sh is already exist!"
			else
				echo "insert ::respawn:-/bin/sh"
				sed -i '/GENERIC_SERIAL/a ::respawn:-/bin/sh' ${TARGET_DIR}/etc/inittab
			fi
		fi
	fi
}

add_preinit_to_inittab

# ==================== T113S3-CORE 板级定制 ====================
board_customize() {
	SDK_ROOT=$(cd "$(dirname "$0")/../../.." 2>/dev/null && pwd)
	OVERLAY=$SDK_ROOT/device/config/chips/t113/configs/t113s3-core/rootfs-overlay

	if [ -d "$OVERLAY" ]; then
		echo "==> install board overlay from $OVERLAY"
		cp -a "$OVERLAY"/. ${TARGET_DIR}/
		[ -f ${TARGET_DIR}/etc/wpa_supplicant.conf ] && chmod 600 ${TARGET_DIR}/etc/wpa_supplicant.conf
		[ -f ${TARGET_DIR}/etc/init.d/S65wifi ] && chmod 755 ${TARGET_DIR}/etc/init.d/S65wifi
		[ -f ${TARGET_DIR}/etc/init.d/S68frpc ] && chmod 755 ${TARGET_DIR}/etc/init.d/S68frpc
		[ -f ${TARGET_DIR}/usr/bin/frpc ] && chmod 755 ${TARGET_DIR}/usr/bin/frpc
		[ -f ${TARGET_DIR}/etc/frp/frpc.toml ] && chmod 644 ${TARGET_DIR}/etc/frp/frpc.toml
	else
		echo "==> WARNING: overlay not found: $OVERLAY"
	fi

	# 清掉参考板遗留的启动脚本（日志噪音）
	rm -f ${TARGET_DIR}/etc/init.d/S50postgresql
	rm -f ${TARGET_DIR}/etc/init.d/S50powerkey_display
	rm -f ${TARGET_DIR}/etc/init.d/S50powerkey_suspend
	rm -f ${TARGET_DIR}/etc/init.d/S99swupdate_autorun

	echo "==> board customize done"
}
board_customize
