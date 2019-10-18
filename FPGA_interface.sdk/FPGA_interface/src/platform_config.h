#ifndef __PLATFORM_CONFIG_H_
#define __PLATFORM_CONFIG_H_


#define PLATFORM_EMAC_BASEADDR XPAR_XEMACPS_0_BASEADDR

#define PLATFORM_ZYNQ

#define RECV_BUF_SIZE 		1480 // Max TCP Payload over 1500 MTU of Ethernet
#define MAX_SIGNAL_LENGTH 	RECV_BUF_SIZE/4

void platform_setup_interrupts(void);
void init_platform();
void cleanup_platform();

#endif
