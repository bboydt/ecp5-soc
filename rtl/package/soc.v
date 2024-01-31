// SOC
//

`define ROM0_ORIGIN 'h00000000
`define ROM0_LENGTH 16*1024
`define BRAM0_ORIGIN 'h00004000
`define BRAM0_LENGTH 16*1024

module soc (
    input sys_clk,
    input sys_rst,

    output uart0_tx,
    input uart0_rx,
    output [63:0] gpio_out
);

    // Slave Address Ranges
    //
    
    WISHBONE_ADDR_RANGE(ROM0, 32'(ROM0_ORIGIN), 32'(ROM0_LENGTH));
    WISHBONE_ADDR_RANGE(BRAM0, 32'(BRAM0_ORIGIN), 32'(BRAM0_LENGTH);

    // Interconnect
    //
    
    arbitrator #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .MASTER_COUNT(1),
        .SLAVE_COUNT(2),
        .SLAVE_ADDR({ROM0_ADDR, BRAM0_ADDR}),
        .SLAVE_MASK({ROM0_MASK, BRAM0_MASK})
    ) arb0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),

        .master_cyc ({cpu0_cyc}),
        .master_stb ({cpu0_stb}),
        .master_we  ({cpu0_we}),
        .master_tag ({cpu0_tag}),
        .master_sel ({cpu0_sel}),
        .master_adr ({cpu0_adr}),
        .master_mosi({cpu0_mosi}),
        .master_miso({cpu0_miso}),
        .master_ack ({cpu0_ack}),
        .master_err ({cpu0_err}),

        .slave_cyc ({rom0_cyc,  bram0_cyc}),
        .slave_stb ({rom0_stb,  bram0_stb}),
        .slave_we  ({rom0_we,   bram0_we}),
        .slave_tag ({rom0_tag,  bram0_tag}),
        .slave_sel ({rom0_sel,  bram0_sel}),
        .slave_adr ({rom0_adr,  bram0_adr}),
        .slave_mosi({rom0_mosi, bram0_mosi}),
        .slave_miso({rom0_miso, bram0_miso}),
        .slave_ack ({rom0_ack,  bram0_ack}),
        .slave_err ({rom0_err,  bram0_err})
    );

    // CPU0
    //

    `WISHBONE_WIRES(cpu0);
    neorv32_wrapper cpu0 (
        .sys_clk(sys_clk),
        .sys_rst_n(~sys_rst),
        `WISHBONE_PORT(bus, cpu0),

        .uart0_tx(uart0_tx),
        .uart0_rx(uart0_rx),
        .gpio_out(gpio)
    );

    // ROM0
    //

    `WISHBONE_WIRES(rom0);
    rom #(
        .ADDR_WIDTH(32),
        .LENGTH(16*1024),
        .INIT_FILE("rand.init")
    ) rom0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        `WISHBONE_PORT(wb, rom0)
    );

    // BRAM0
    //

    `WISHBONE_WIRES(bram0);
    bram #(
        .ADDR_WIDTH(32),
        .LENGTH(16*1024)
    ) bram0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        `WISHBONE_PORT(wb, bram0)
    );

endmodule
