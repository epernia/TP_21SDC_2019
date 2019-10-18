#include "dma.h"


extern SemaphoreHandle_t DMAToFPGABinarySemaphore;
extern SemaphoreHandle_t DMAFromFPGABinarySemaphore;


/*
 * Inicialización del DMA
 */
int initializeAXIDMA( XAxiDma *dma, unsigned int DEVICE_ID )
{
    XAxiDma_Config *cfg;
	int status;

	cfg = XAxiDma_LookupConfig(DEVICE_ID);
	if (!cfg){
		xil_printf("ERROR: No configuration found for AXI DMA with device ID %d.\n\r", DEVICE_ID);
	    return XST_FAILURE;
	}
#ifdef DMA_DEBUG_ON
	xil_printf("DMA: INFO - Configuration found.\n\r");
#endif

	status = XAxiDma_CfgInitialize(dma, cfg);
	if (status != XST_SUCCESS){
		xil_printf("ERROR: DMA configuration failed.\n\r");
	    return XST_FAILURE;
	}
#ifdef DMA_DEBUG_ON
	xil_printf("DMA: INFO - Configuration applied.\n\r");
#endif

	// Test for Scatter Gather
	if (XAxiDma_HasSg(dma)){
		xil_printf("ERROR: DMA device configured as SG mode.\n\r");
		return XST_FAILURE;
	}

#ifdef DMA_DEBUG_ON
	xil_printf("DMA: INFO - About to reset DMA.\n\r");
#endif
	// Reset DMA
	XAxiDma_Reset(dma);
	while (!XAxiDma_ResetIsDone(dma)){}
#if DMA_DEBUG_ON
	xil_printf("DMA: INFO - DMA reseted.\n\r");
#endif

	//XAxiDma_IntrEnable(dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	return XST_SUCCESS;
}


void dma_fromPL_callback(void *callback)
{
#if DMA_DEBUG_ON
	xil_printf("DMA: Interrupted!\n\r");
#endif

	BaseType_t xHigherPriorityTaskWoken;

    /* The xHigherPriorityTaskWoken parameter must be initialized to pdFALSE
     * because it will get set to pdTRUE inside the interrupt-safe API function
     * if a context switch is required. */
    xHigherPriorityTaskWoken = pdFALSE;


    int status;
    XAxiDma *axidma = (XAxiDma *)callback;

    // Disable interrupts on DMA
    XAxiDma_IntrDisable(axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    // Read pending interrupts
    status = XAxiDma_IntrGetIrq(axidma, XAXIDMA_DEVICE_TO_DMA);
    // Acknowledge pending interrupts
    XAxiDma_IntrAckIrq(axidma, status, XAXIDMA_DEVICE_TO_DMA);
    // If no interrupt is asserted, nothing to do
    if (!(status & XAXIDMA_IRQ_ALL_MASK)) return;
    // Reset DMA engine if there was an error
    if (status & XAXIDMA_IRQ_ERROR_MASK) {
    	xil_printf("WARNING: Error Interrupt on DMA!\n\r");
    	XAxiDma_Reset(axidma);
    	while (!XAxiDma_ResetIsDone(axidma))
    	return;
    }
    if (status & XAXIDMA_IRQ_IOC_MASK){
    	/* Give the semaphore to unblock the task, passing in the address of
		 * xHigherPriorityTaskWoken as the interrupt-safe API function's
		 * pxHigherPriorityTaskWoken parameter. */
    	xil_printf("Data received from FPGA.\n\r");
		xSemaphoreGiveFromISR( DMAFromFPGABinarySemaphore, &xHigherPriorityTaskWoken );

		/* Pass the xHigherPriorityTaskWoken value into portYIELD_FROM_ISR().
		 * If xHigherPriorityTaskWoken was set to pdTRUE inside xSemaphoreGiveFromISR(),
		 * then calling portYIELD_FROM_ISR() will request a context switch.
		 * If xHigherPriorityTaskWoken is still pdFALSE, then calling portYIELD_FROM_ISR()
		 * will have no effect. */
		portYIELD_FROM_ISR( xHigherPriorityTaskWoken );

#if DMA_DEBUG_ON
		xil_printf("Shared Buffer =");
		for (int j=0; j<SIGNAL_LENGTH; j++)
			xil_printf(" [%d]=%08x", j, sharedMemoryBuffer[j]);
		xil_printf("\n\r");
#endif
    }
}

void dma_toPL_callback(void *callback)
{
	BaseType_t xHigherPriorityTaskWoken;

    /* The xHigherPriorityTaskWoken parameter must be initialized to pdFALSE
     * because it will get set to pdTRUE inside the interrupt-safe API function
     * if a context switch is required. */
    xHigherPriorityTaskWoken = pdFALSE;


    int status;
    XAxiDma *axidma = (XAxiDma *)callback;

    // Disable interrupts on DMA
    XAxiDma_IntrDisable(axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
    // Read pending interrupts
    status = XAxiDma_IntrGetIrq(axidma, XAXIDMA_DMA_TO_DEVICE);
    // Acknowledge pending interrupts
    XAxiDma_IntrAckIrq(axidma, status, XAXIDMA_DMA_TO_DEVICE);
    // If no interrupt is asserted, nothing to do
    if (!(status & XAXIDMA_IRQ_ALL_MASK)) return;
    // Reset DMA engine if there was an error
    if (status & XAXIDMA_IRQ_ERROR_MASK) {
    	xil_printf("WARNING: Error Interrupt on DMA!\n\r");
    	XAxiDma_Reset(axidma);
    	while (!XAxiDma_ResetIsDone(axidma))
    	return;
    }
    if (status & XAXIDMA_IRQ_IOC_MASK){
    	/* Give the semaphore to unblock the task, passing in the address of
		 * xHigherPriorityTaskWoken as the interrupt-safe API function's
		 * pxHigherPriorityTaskWoken parameter. */
    	xil_printf("Data sent to FPGA.\n\r");
    	xSemaphoreGiveFromISR( DMAToFPGABinarySemaphore, &xHigherPriorityTaskWoken );
		/* Pass the xHigherPriorityTaskWoken value into portYIELD_FROM_ISR().
		 * If xHigherPriorityTaskWoken was set to pdTRUE inside xSemaphoreGiveFromISR(),
		 * then calling portYIELD_FROM_ISR() will request a context switch.
		 * If xHigherPriorityTaskWoken is still pdFALSE, then calling portYIELD_FROM_ISR()
		 * will have no effect. */
		portYIELD_FROM_ISR( xHigherPriorityTaskWoken );
    }
}
