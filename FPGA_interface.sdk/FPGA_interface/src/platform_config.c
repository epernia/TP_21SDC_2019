/*
* platform_zynq.c
*
* Zynq platform specific functions.
*
* The functions in this file are related to the hardware of this platform.
* The EmacPs has a HW bug on the Rx path for heavy Rx traffic.
* Under heavy Rx traffic because of the HW bug there are times when the Rx path
* becomes unresponsive. The workaround for it is to check for the Rx path for
* traffic (by reading the stats registers regularly). If the stats register
* does not increment for sometime (proving no Rx traffic), the function resets
* the Rx data path.
*
*/

#ifdef __arm__

#include "xparameters.h"
#include "xparameters_ps.h"	/* defines XPAR values */
#include "xil_cache.h"
#include "xscugic.h"
#include "lwip/tcp.h"
#include "xil_printf.h"
#include "netif/xadapter.h"
#include "platform_config.h"
#ifdef PLATFORM_ZYNQ
#include "dma.h"
#include "xaxidma.h"

#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID
#define TIMER_DEVICE_ID		XPAR_SCUTIMER_DEVICE_ID
#define INTC_BASE_ADDR		XPAR_SCUGIC_0_CPU_BASEADDR
#define INTC_DIST_BASE_ADDR	XPAR_SCUGIC_0_DIST_BASEADDR
#define TIMER_IRPT_INTR		XPAR_SCUTIMER_INTR

#define RESET_RX_CNTR_LIMIT	400

void tcp_fasttmr(void);
void tcp_slowtmr(void);


#ifndef USE_SOFTETH_ON_ZYNQ
extern struct netif netiface;
extern XScuGic xInterruptController;
#endif

volatile int TcpFastTmrFlag = 0;
volatile int TcpSlowTmrFlag = 0;

#if LWIP_DHCP==1
volatile int dhcp_timoutcntr = 24;
void dhcp_fine_tmr();
void dhcp_coarse_tmr();
#endif

extern XAxiDma dma;
extern u32 sharedToFPGABuffer[MAX_SIGNAL_LENGTH];		// DMA shared memory
extern u32 sharedFromFPGABuffer[MAX_SIGNAL_LENGTH];		// DMA shared memory

void platform_setup_interrupts(void)
{
	BaseType_t xStatus;
	XScuGic_Config *pxGICConfig;

	/* Ensure no interrupts execute while the scheduler is in an inconsistent
	state.  Interrupts are automatically enabled when the scheduler is
	started. */
	portDISABLE_INTERRUPTS();

	/* Obtain the configuration of the GIC. */
	pxGICConfig = XScuGic_LookupConfig( XPAR_SCUGIC_SINGLE_DEVICE_ID );

	/* Sanity check the FreeRTOSConfig.h settings are correct for the
	hardware. */
	configASSERT( pxGICConfig );
	configASSERT( pxGICConfig->CpuBaseAddress == ( configINTERRUPT_CONTROLLER_BASE_ADDRESS + configINTERRUPT_CONTROLLER_CPU_INTERFACE_OFFSET ) );
	configASSERT( pxGICConfig->DistBaseAddress == configINTERRUPT_CONTROLLER_BASE_ADDRESS );

	/* Install a default handler for each GIC interrupt. */
	xStatus = XScuGic_CfgInitialize( &xInterruptController, pxGICConfig, pxGICConfig->CpuBaseAddress );
	configASSERT( xStatus == XST_SUCCESS );
	( void ) xStatus; /* Remove compiler warning if configASSERT() is not defined. */

	/* DMA */

	// PS -> PL
	XScuGic_RegisterHandler(/*INTC_BASE_ADDR*/pxGICConfig->CpuBaseAddress,	XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,
							(Xil_ExceptionHandler)dma_fromPL_callback,
							(void *)&dma);

	// PL -> PS
	XScuGic_RegisterHandler(/*INTC_BASE_ADDR*/pxGICConfig->CpuBaseAddress,	XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR,
							(Xil_ExceptionHandler)dma_toPL_callback,
							(void *)&dma);

	/* Enable the interrupt for DMA */
	XScuGic_EnableIntr(INTC_DIST_BASE_ADDR, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
	XScuGic_EnableIntr(INTC_DIST_BASE_ADDR, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR);

	return;
}

void init_platform()
{
	int status;

    /* DMA */
    xil_printf("Initializing DMA...\n\r");
	status = initializeAXIDMA(&dma, XPAR_AXIDMA_0_DEVICE_ID);
	if (status == XST_SUCCESS)
		xil_printf("DMA Inicializado.\n\r");
	else
		xil_printf("ERROR: DMA Init() returned with error.\n\r");

	/* Interrupts */
	xil_printf("Setting up Interrupts...\n\r");
	platform_setup_interrupts();
	xil_printf("Interrupts enabled.\n\r");

	return;
}

void cleanup_platform()
{
	Xil_ICacheDisable();
	Xil_DCacheDisable();
	return;
}

#endif
#endif
