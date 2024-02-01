/* This address space is based on a neorv32 config without IMEM, DMEM, XIP, 
 * or their bootloader. So, those address spaces go to the wishbone interconnect
 * which we can respond to requests on with our own ROM, SRAM, and DRAM cores.
 * 
 * ROM  - bootrom code
 * SRAM - fpga bram because vrooooooom
 * DRAM - part of one of the two 4GB dram chips
 * IOPREF - processor-internal peripherals / IO devices.
 */

MEMORY
{
    ROM  : ORIGIN = 0x00000000, LENGTH = 16K
    SRAM : ORIGIN = 0x00004000, LENGTH = 16K
}

