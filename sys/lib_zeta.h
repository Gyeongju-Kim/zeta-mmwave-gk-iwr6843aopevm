#ifndef __LIB_ZETA_H__
#define __LIB_ZETA_H__
uint32_t ms_to_ticks(uint32_t ms);
void zeta_open_uart_handle(int mode);
void zeta_putstr(const char *s);
void zeta_close_uart_handle();
void zeta_open_cli_handle(uint8_t taskPriority);
void zeta_putcli(const char *s);
#endif
