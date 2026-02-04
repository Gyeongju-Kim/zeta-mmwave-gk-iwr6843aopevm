#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

/* XDCtools Header files */
#include <xdc/std.h>
#include <xdc/cfg/global.h>
#include <xdc/runtime/Error.h>
#include <xdc/runtime/System.h>

/* BIOS Header files */
#include <ti/sysbios/BIOS.h>
#include <ti/sysbios/knl/Task.h>
#include <ti/sysbios/knl/Clock.h>

/* mmWave SK Include Files: */
#include <ti/drivers/uart/UART.h>
#include <ti/utils/cli/cli.h>
#include <ti/drivers/pinmux/pinmux.h>

UART_Handle gUartHandle;

#define MMWAVE_SDK_VERSION_BUILD  4
#define MMWAVE_SDK_VERSION_BUGFIX 0
#define MMWAVE_SDK_VERSION_MINOR  5
#define MMWAVE_SDK_VERSION_MAJOR  3

#define ZETA_TAG_UART   "\n\r\x1b[34m[UART]\x1b[0m "
#define ZETA_TAG_CLI    "\n\r\x1b[32m[CLI]\x1b[0m  "



extern uint32_t gCPUClockFrequency;
extern DMA_Handle   gDMAHandle;

int32_t ZetaDemo_Test(int32_t argc, char* argv[]);

// timer

uint32_t ms_to_ticks(uint32_t ms)
{
    uint32_t tick_us = Clock_tickPeriod;   // microseconds
    uint32_t us = ms * 1000U;
    return (us + tick_us - 1U) / tick_us;  // ceil
}

// uart

void zeta_open_uart_handle(int mode) {
    UART_Params     params;

    /* Setup the default UART Parameters */
    UART_Params_init(&params); // set default values
    params.clockFrequency = gCPUClockFrequency;
    params.isPinMuxDone   = 1;
    if(mode == 1) {  // DMA mode
        params.readDataMode   = UART_DATA_BINARY;
        params.writeDataMode  = UART_DATA_BINARY;
        params.readEcho       = UART_ECHO_OFF;
        params.dmaHandle      = gDMAHandle;
        params.txDMAChannel   = 1;
        params.rxDMAChannel   = 2;
    }
    
    gUartHandle = UART_open(0, &params);
}

void zeta_close_uart_handle() {
    UART_close(gUartHandle);
}


void zeta_putstr(const char *s)
{
    if (s == NULL || gUartHandle == NULL)
    {
        return;
    }

    UART_write(gUartHandle,
               (uint8_t*)ZETA_TAG_UART,
               strlen(ZETA_TAG_UART));

    UART_write(gUartHandle,
               (uint8_t*)s,
               strlen(s));
}

// cli

int32_t ZetaDemo_Test(int32_t argc, char* argv[])
{
    int32_t i;

    CLI_write("%sZetaDemo_Test called\n", ZETA_TAG_CLI);
    CLI_write("%sargc = %d\n", ZETA_TAG_CLI, argc);

    for (i = 0; i < argc; i++)
    {
        CLI_write("%sargv[%d] = %s\n", ZETA_TAG_CLI, i, argv[i]);
    }

    /* 예시: 인자 검사 */
    if (argc == 1)
    {
        CLI_write("%sNo arguments given\n", ZETA_TAG_CLI);
    }
    else
    {
        CLI_write("%sArguments detected\n", ZETA_TAG_CLI);
    }

    return 0;   // 0 = CLI 성공
}


void zeta_open_cli_handle(uint8_t taskPriority) {
    zeta_open_uart_handle(0); // Non-DMA mode

    CLI_Cfg     cliCfg;
    char        demoBanner[256];
    uint32_t    cnt;

    /* Create Demo Banner to be printed out by CLI */
    sprintf(&demoBanner[0], 
                       "\n\r******************************************\n" \
                       "xWR68xx MMW Demo %02d.%02d.%02d.%02d\n"  \
                       "******************************************\n", 
                        MMWAVE_SDK_VERSION_MAJOR,
                        MMWAVE_SDK_VERSION_MINOR,
                        MMWAVE_SDK_VERSION_BUGFIX,
                        MMWAVE_SDK_VERSION_BUILD
            );

    memset ((void *)&cliCfg, 0, sizeof(CLI_Cfg));

    cliCfg.cliPrompt                    = "zetaDemo:/>";
    cliCfg.cliBanner                    = demoBanner;
    cliCfg.cliUartHandle                = gUartHandle;
    cliCfg.taskPriority                 = taskPriority;
    cliCfg.usePolledMode                = true;
    cliCfg.overridePlatform             = false;
    cliCfg.overridePlatformString       = NULL;    
    
    cliCfg.tableEntry[0].cmd = NULL;

    cnt=0;
    cliCfg.tableEntry[cnt].cmd            = "TestCmd";
    cliCfg.tableEntry[cnt].helpString     = "No arguments";
    cliCfg.tableEntry[cnt].cmdHandlerFxn  = ZetaDemo_Test;
    cnt++;


        /* Open the CLI: */
    if (CLI_open (&cliCfg) < 0)
    {
        System_printf ("Error: Unable to open the CLI\n");
        return;
    }
    
    System_printf ("Debug: CLI is operational\n");
    return;
}

void zeta_putcli(const char *s)
{
    if (s == NULL)
    {
        return;
    }

    CLI_write("%s%s", ZETA_TAG_CLI, s);
}
