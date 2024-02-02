// SOC
//

`include "utils/wishbone.v"
`include "package/interconnect.v"
`include "cores/rom.v"
`include "cores/bram.v"
`include "neorv32_wrapper.v"


module soc #(
    // Set EXT_MASTER_COUNT and EXT_SLAVE_COUNT to enable master and slave ports for external cores.
    parameter EXT_MASTER_COUNT = 0,
    parameter EXT_SLAVE_COUNT = 0
) (
    input sys_clk,
    input sys_rst,

    `WISHBONE_MASTER_ARRAY(ext_masters, EXT_MASTER_COUNT),
    `WISHBONE_SLAVE_ARRAY(ext_slaves, EXT_SLAVE_COUNT),

    output uart0_tx,
    input uart0_rx,
    output [63:0] gpio_out
);

    // Master and Slave Counts
    //

    localparam INT_MASTER_COUNT = 1;
    localparam INT_SLAVE_COUNT = 2;

    localparam MASTER_COUNT = (EXT_MASTER_COUNT != 0 ? EXT_MASTER_COUNT : 1) + INT_MASTER_COUNT;
    localparam SLAVE_COUNT = EXT_SLAVE_COUNT + INT_SLAVE_COUNT;

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
    
    generate 

    if (EXT_MASTER_COUNT == 0) begin
        `WISHBONE_WIRES(dummy);
        interconnect #(
            .DATA_WIDTH(32),
            .ADDR_WIDTH(32),
            .MASTER_COUNT(MASTER_COUNT),
            .SLAVE_COUNT(SLAVE_COUNT),
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

            .slave_cyc ({rom0_cyc , bram0_cyc , ext_slaves_cyc }),
            .slave_stb ({rom0_stb , bram0_stb , ext_slaves_stb }),
            .slave_we  ({rom0_we  , bram0_we  , ext_slaves_we  }),
            .slave_tag ({rom0_tag , bram0_tag , ext_slaves_tag }),
            .slave_sel ({rom0_sel , bram0_sel , ext_slaves_sel }),
            .slave_adr ({rom0_adr , bram0_adr , ext_slaves_adr }),
            .slave_mosi({rom0_mosi, bram0_mosi, ext_slaves_mosi}),
            .slave_miso({rom0_miso, bram0_miso, ext_slaves_miso}),
            .slave_ack ({rom0_ack , bram0_ack , ext_slaves_ack }),
            .slave_err ({rom0_err , bram0_err , ext_slaves_err })
        );
    end else begin
        interconnect #(
            .DATA_WIDTH(32),
            .ADDR_WIDTH(32),
            .MASTER_COUNT(MASTER_COUNT),
            .SLAVE_COUNT(SLAVE_COUNT),
            .SLAVE_ADDR({ROM0_ADDR, BRAM0_ADDR}),
            .SLAVE_MASK({ROM0_MASK, BRAM0_MASK})
        ) interconnect0 (
            .sys_clk(sys_clk),
            .sys_rst(sys_rst),

            .master_cyc ({cpu0_cyc , ext_masters_cyc }),
            .master_stb ({cpu0_stb , ext_masters_stb }),
            .master_we  ({cpu0_we  , ext_masters_we  }),
            .master_tag ({cpu0_tag , ext_masters_tag }),
            .master_sel ({cpu0_sel , ext_masters_sel }),
            .master_adr ({cpu0_adr , ext_masters_adr }),
            .master_mosi({cpu0_mosi, ext_masters_mosi}),
            .master_miso({cpu0_miso, ext_masters_miso}),
            .master_ack ({cpu0_ack , ext_masters_ack }),
            .master_err ({cpu0_err , ext_masters_err }),

            .slave_cyc ({rom0_cyc , bram0_cyc , ext_slaves_cyc }),
            .slave_stb ({rom0_stb , bram0_stb , ext_slaves_stb }),
            .slave_we  ({rom0_we  , bram0_we  , ext_slaves_we  }),
            .slave_tag ({rom0_tag , bram0_tag , ext_slaves_tag }),
            .slave_sel ({rom0_sel , bram0_sel , ext_slaves_sel }),
            .slave_adr ({rom0_adr , bram0_adr , ext_slaves_adr }),
            .slave_mosi({rom0_mosi, bram0_mosi, ext_slaves_mosi}),
            .slave_miso({rom0_miso, bram0_miso, ext_slaves_miso}),
            .slave_ack ({rom0_ack , bram0_ack , ext_slaves_ack }),
            .slave_err ({rom0_err , bram0_err , ext_slaves_err })
        );
    end
    endgenerate

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
