// SOC
//

`include "utils/wishbone.v"
`include "package/interconnect.v"
`include "cores/rom.v"
`include "cores/bram.v"
`include "neorv32_wrapper.v"


module soc (
    input sys_clk,
    input sys_rst,

    output uart0_tx,
    input uart0_rx,
    output [63:0] gpio_out
);

    // Slave Address Ranges
    //

    localparam ROM0_ADDR = 32'h00000000;
    localparam ROM0_MASK = 32'(`ROM0_LENGTH-1);
    localparam BRAM0_ADDR = 32'h00004000;
    localparam BRAM0_MASK = 32'(`BRAM0_LENGTH-1);
    
    initial begin
        $display("");
        $display(":: SoC Slave Address Map ::");
        $display("ROM0_MASK = 0x%X", ROM0_ADDR);
        $display("ROM0_ADDR = 0x%X", ROM0_MASK);
        $display("BRAM0_MASK = 0x%X", BRAM0_ADDR);
        $display("BRAM0_ADDR = 0x%X", BRAM0_MASK);
        $display("");
    end

    // Interconnect
    //
    
    `WISHBONE_WIRES(dummy);

    interconnect #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .MASTER_COUNT(2),
        .SLAVE_COUNT(2),
        .SLAVE_ADDR({ROM0_ADDR, BRAM0_ADDR}),
        .SLAVE_MASK({ROM0_MASK, BRAM0_MASK})
    ) interconnect0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),

        .master_cyc ({dummy_cyc ,  cpu0_cyc }),
        .master_stb ({dummy_stb ,  cpu0_stb }),
        .master_we  ({dummy_we  ,  cpu0_we  }),
        .master_tag ({dummy_tag ,  cpu0_tag }),
        .master_sel ({dummy_sel ,  cpu0_sel }),
        .master_adr ({dummy_adr ,  cpu0_adr }),
        .master_mosi({dummy_mosi,  cpu0_mosi}),
        .master_miso({dummy_miso,  cpu0_miso}),
        .master_ack ({dummy_ack ,  cpu0_ack }),
        .master_err ({dummy_err ,  cpu0_err }),

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
        .gpio_out(gpio_out)
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
