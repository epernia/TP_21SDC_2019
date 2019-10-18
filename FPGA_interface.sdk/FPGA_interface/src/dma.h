#ifndef DMA__H
#define DMA__H

#include "xaxidma.h"
#include "FreeRTOS.h"
#include "semphr.h"

#define DMA_DEBUG_ON 0

int initializeAXIDMA(XAxiDma *, unsigned int );
void dma_fromPL_callback(void *callback);
void dma_toPL_callback(void *callback);


#endif	/* DMA__H */
