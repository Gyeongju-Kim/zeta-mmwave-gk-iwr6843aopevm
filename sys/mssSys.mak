###################################################################################
# System on MSS Makefile
###################################################################################
.PHONY: mssSys mssSysClean

###################################################################################
# Setup the VPATH:
###################################################################################
vpath %.c src
vpath %.c sys

###################################################################################
# The System requires additional libraries
###################################################################################
SYS_STD_LIBS = $(R4F_COMMON_STD_LIB)										\
						  -llibpinmux_$(MMWAVE_SDK_DEVICE_TYPE).$(R4F_LIB_EXT)		\
						  -llibdma_$(MMWAVE_SDK_DEVICE_TYPE).$(R4F_LIB_EXT)			\
					      -llibtestlogger_$(MMWAVE_SDK_DEVICE_TYPE).$(R4F_LIB_EXT)  \
						  -llibcli_$(MMWAVE_SDK_DEVICE_TYPE).$(R4F_LIB_EXT)
SYS_LOC_LIBS = $(R4F_COMMON_LOC_LIB)									\
						  -i$(MMWAVE_SDK_INSTALL_PATH)/ti/drivers/pinmux/lib	\
						  -i$(MMWAVE_SDK_INSTALL_PATH)/ti/drivers/dma/lib		\
						  -i$(MMWAVE_SDK_INSTALL_PATH)/ti/utils/testlogger/lib  \
						  -i$(MMWAVE_SDK_INSTALL_PATH)/ti/utils/cli/lib

###################################################################################
# System Files
###################################################################################
SYS_CFG	 	 = sys/mss.cfg
SYS_CMD       = $(MMWAVE_SDK_INSTALL_PATH)/ti/platform/$(MMWAVE_SDK_DEVICE_TYPE)
SYS_CONFIGPKG = sys/mss_configPkg_$(MMWAVE_SDK_DEVICE_TYPE)
SYS_MAP       = sys/$(MMWAVE_SDK_DEVICE_TYPE)_sys_mss.map
SYS_OUT       = sys/$(MMWAVE_SDK_DEVICE_TYPE)_sys_mss.$(R4F_EXE_EXT)
SYS_BIN       = sys/$(MMWAVE_SDK_DEVICE_TYPE)_sys_mss.bin
SYS_APP_CMD   = sys/mss_sys_linker.cmd
SYS_SOURCES   = $(UART_DRV_SOURCES) 		\
						   main_mss.c 				\
						   uart_test.c				\
                           uart_echo.c		\
						   lib_zeta.c		
SYS_DEPENDS 	 = $(addprefix $(PLATFORM_OBJDIR)/, $(SYS_SOURCES:.c=.$(R4F_DEP_EXT)))
SYS_OBJECTS 	 = $(addprefix $(PLATFORM_OBJDIR)/, $(SYS_SOURCES:.c=.$(R4F_OBJ_EXT)))

###################################################################################
# RTSC Configuration:
###################################################################################
sysRTSC:
	@echo 'Configuring RTSC packages...'
	$(XS) --xdcpath="$(XDCPATH)" xdc.tools.configuro $(R4F_XSFLAGS) -o $(SYS_CONFIGPKG) $(SYS_CFG)
	@echo 'Finished configuring packages'
	@echo ' '

###################################################################################
# Build Unit Test:
###################################################################################
mssSys: BUILD_CONFIGPKG=$(SYS_CONFIGPKG)
mssSys: R4F_CFLAGS += --cmd_file=$(BUILD_CONFIGPKG)/compiler.opt
mssSys: buildDirectories sysRTSC $(SYS_OBJECTS)
	$(R4F_LD) $(R4F_LDFLAGS) $(SYS_LOC_LIBS) $(SYS_STD_LIBS) 	\
	-l$(SYS_CONFIGPKG)/linker.cmd --map_file=$(SYS_MAP) 		\
	$(SYS_OBJECTS) $(PLATFORM_R4F_LINK_CMD) $(SYS_APP_CMD) 	\
	$(R4F_LD_RTS_FLAGS) -o $(SYS_OUT)
	@echo '******************************************************************************'
	@echo 'Built the System MSS '
	@echo '******************************************************************************'

###################################################################################
# Cleanup Unit Test:
###################################################################################
sysClean:
	@echo 'Cleaning the System MSS objects'
	@$(DEL) $(SYS_OBJECTS) $(SYS_OUT) $(SYS_BIN)
	@$(DEL) $(SYS_MAP) $(SYS_DEPENDS)
	@echo 'Cleaning the System MSS RTSC package'
	@$(DEL) $(SYS_CONFIGPKG)
	@$(DEL) $(PLATFORM_OBJDIR)

###################################################################################
# Dependency handling
###################################################################################
-include $(SYS_DEPENDS)

