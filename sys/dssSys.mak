###################################################################################
# System on DSS
###################################################################################
.PHONY: dssSys dssSysClean

###################################################################################
# Setup the VPATH:
###################################################################################
vpath %.c src
vpath %.c sys

###################################################################################
# The system requires additional libraries
###################################################################################
SYS_DSS_STD_LIBS = $(C674_COMMON_STD_LIB)										\
					     -llibedma_$(MMWAVE_SDK_DEVICE_TYPE).$(C674_LIB_EXT)		\
					     -llibtestlogger_$(MMWAVE_SDK_DEVICE_TYPE).$(C674_LIB_EXT)
SYS_DSS_LOC_LIBS = $(C674_COMMON_LOC_LIB)									\
						 -i$(MMWAVE_SDK_INSTALL_PATH)/ti/drivers/edma/lib		\
						 -i$(MMWAVE_SDK_INSTALL_PATH)/ti/utils/testlogger/lib

###################################################################################
# System files
###################################################################################
SYS_DSS_CFG	      = sys/dss.cfg
SYS_DSS_CMD       = $(MMWAVE_SDK_INSTALL_PATH)/ti/platform/$(MMWAVE_SDK_DEVICE_TYPE)
SYS_DSS_CONFIGPKG = sys/dss_configPkg_$(MMWAVE_SDK_DEVICE_TYPE)
SYS_DSS_MAP       = sys/$(MMWAVE_SDK_DEVICE_TYPE)_sys_dss.map
SYS_DSS_OUT       = sys/$(MMWAVE_SDK_DEVICE_TYPE)_sys_dss.$(C674_EXE_EXT)
SYS_DSS_BIN       = sys/$(MMWAVE_SDK_DEVICE_TYPE)_sys_dss.bin
SYS_DSS_APP_CMD   = sys/dss_sys_linker.cmd
SYS_DSS_SOURCES   = $(UART_DRV_SOURCES) 		\
						  main_dss.c				\
						  uart_test.c
SYS_DSS_DEPENDS   = $(addprefix $(PLATFORM_OBJDIR)/, $(SYS_DSS_SOURCES:.c=.$(C674_DEP_EXT)))
SYS_DSS_OBJECTS   = $(addprefix $(PLATFORM_OBJDIR)/, $(SYS_DSS_SOURCES:.c=.$(C674_OBJ_EXT)))

###################################################################################
# RTSC Configuration:
###################################################################################
dssRTSC:
	@echo 'Configuring RTSC packages...'
	$(XS) --xdcpath="$(XDCPATH)" xdc.tools.configuro $(C674_XSFLAGS) -o $(SYS_DSS_CONFIGPKG) $(SYS_DSS_CFG)
	@echo 'Finished configuring packages'
	@echo ' '

###################################################################################
# Build System
###################################################################################
dssSys: BUILD_CONFIGPKG=$(SYS_DSS_CONFIGPKG)
dssSys: C674_CFLAGS += --cmd_file=$(BUILD_CONFIGPKG)/compiler.opt
dssSys: buildDirectories dssRTSC $(SYS_DSS_OBJECTS)
	$(C674_LD) $(C674_LDFLAGS) $(SYS_DSS_LOC_LIBS) $(SYS_DSS_STD_LIBS) 						\
	-l$(SYS_DSS_CONFIGPKG)/linker.cmd --map_file=$(SYS_DSS_MAP) $(SYS_DSS_OBJECTS) 	\
	$(PLATFORM_C674X_LINK_CMD) $(SYS_DSS_APP_CMD) $(C674_LD_RTS_FLAGS) -lrts6740_elf.lib -o $(SYS_DSS_OUT)
	@echo '******************************************************************************'
	@echo 'Built System DSS'
	@echo '******************************************************************************'

###################################################################################
# Cleanup System:
###################################################################################
dssSysClean:
	@echo 'Cleaning the System DSS objects'
	@$(DEL) $(SYS_DSS_OBJECTS) $(SYS_DSS_OUT)
	@$(DEL) $(SYS_DSS_BIN) $(SYS_DSS_DEPENDS)
	@$(DEL) $(SYS_DSS_MAP)
	@echo 'Cleaning the System DSS RTSC package'
	@$(DEL) $(SYS_DSS_CONFIGPKG)
	@$(DEL) $(PLATFORM_OBJDIR)

###################################################################################
# Dependency handling
###################################################################################
-include $(SYS_DSS_DEPENDS)

