
SDK_INSTALL=C:/ti/mmwave_sdk_03_05_00_04
UNIFLASH_INSTALL=C:/ti/uniflash_9.2.0

##################################################################################
# Zeta system makefile
##################################################################################
include ../../common/mmwave_sdk.mak
include ./uartlib.mak

##################################################################################
# SOC Specific Test Targets
##################################################################################
include ./sys/mssSys.mak
include ./sys/dssSys.mak

###################################################################################
# Standard Targets which need to be implemented by each mmWave SDK module. This
# plugs into the release scripts.
###################################################################################
.PHONY: all clean drv drvClean sys sysClean help

##################################################################################
# Build/Clean the driver
##################################################################################

# This builds the UART Driver
drv: uartDrv

# This cleans the UART Driver
drvClean: uartDrvClean

###################################################################################
# Test Targets:
# XWR14xx: Build the MSS Unit Test
# XWR16xx/XWR18xx/XWR68xx: Build the MSS and DSS Unit Test
###################################################################################
binclean:
	rm -f zeta.bin

sysClean: 	mssSysClean dssSysClean binclean
sys: 		mssSys dssSys

# Clean: This cleans all the objects
clean: drvClean sysClean

# postprocessing for binary generation
genbin:
	echo "=== build binary for uniflash"
	$(SDK_INSTALL)/packages/scripts/windows/generateMetaImage.bat zeta.bin 0x00000006 $(SDK_INSTALL)/packages/ti/drivers/zeta/sys/xwr68xx_sys_mss.xer4f $(SDK_INSTALL)/firmware/radarss/xwr6xxx_radarss_rprc.bin $(SDK_INSTALL)/packages/ti/drivers/zeta/sys/xwr68xx_sys_dss.xe674 
	# mv $(SDK_INSTALL)/packages/scripts/windows/zeta.bin $(SDK_INSTALL)/packages/ti/drivers/zeta
postproc: genbin

# flash image to taget
flash:
	@echo "=== image flash. Confirm the setting of SOP2 jumper"
	$(UNIFLASH_INSTALL)/deskdb/content/TICloudAgent/win/ccs_base/DebugServer/bin/DSLite.exe flash -c $(SDK_INSTALL)/packages/ti/drivers/zeta/uniflash/iwr6843AOP.ccxml -l $(SDK_INSTALL)\packages\ti\drivers\zeta\uniflash\generated.ufsettings -e -f $(SDK_INSTALL)/packages/ti/drivers/zeta/zeta.bin,1

# Build everything
all: drv sys postproc

# Help: This displays the MAKEFILE Usage.
help:
	@echo '****************************************************************************************'
	@echo '* Makefile Targets for the UART '
	@echo 'clean                -> Clean out all the objects'
	@echo 'drv                  -> Build the Driver only'
	@echo 'drvClean             -> Clean the Driver Library only'
	@echo 'sys                 -> Builds system for the SOC'
	@echo 'sysClean            -> Cleans the system for the SOC'
	@echo 'flash				-> flash image to target'
	@echo '****************************************************************************************'

