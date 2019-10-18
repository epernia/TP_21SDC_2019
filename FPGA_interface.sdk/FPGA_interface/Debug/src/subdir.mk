################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/dma.c \
../src/echo.c \
../src/iic_phyreset.c \
../src/main.c \
../src/platform_config.c 

OBJS += \
./src/dma.o \
./src/echo.o \
./src/iic_phyreset.o \
./src/main.o \
./src/platform_config.o 

C_DEPS += \
./src/dma.d \
./src/echo.d \
./src/iic_phyreset.d \
./src/main.d \
./src/platform_config.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../FPGA_interface_BSP/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


