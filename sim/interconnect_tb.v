`include "ecp5_soc/utils/wishbone.v"
`include "ecp5_soc/package/interconnect.v"

module wishbone_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input sys_clk,
    input sys_rst,
    `WISHBONE_MASTER(wb)
);

    initial begin
        wb_cyc  <= 0;
        wb_stb  <= 0;
        wb_we   <= 0;
        wb_tag  <= 0;
        wb_sel  <= 0;
        wb_adr  <= 0;
        wb_mosi <= 0;
    end

    always @(posedge sys_clk) begin
        if (~wb_cyc) begin
            // begin request
            wb_cyc <= 1;
            wb_stb <= 1;
        end else if (wb_ack) begin
            // end request
            wb_cyc <= 0;
            wb_stb <= 0;
        end
    end

endmodule

module wishbone_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ORIGIN = 0,
    parameter LENGTH = 0
) (
    input sys_clk,
    input sys_rst,
    `WISHBONE_SLAVE(wb)
);

    initial begin
        wb_miso <= 0;
        wb_ack <= 0;
        wb_err <= 0;
    end

    always @(*) begin
        wb_ack <= wb_stb;
        wb_err <= 0;
    end

endmodule

module testbench(
);

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    localparam MASTER_COUNT = 2;
    localparam SLAVE_COUNT = 2;

    // System Control
    //

    reg sys_clk;
    reg sys_rst;

    // Simulation Control
    //

    always #1 sys_clk <= ~sys_clk;

    integer i;
    initial begin
        $display(":: interconnect_tb.v ::");
        $dumpfile("interconnect.vcd");
        $dumpvars(0, testbench);

        sys_clk <= 0;
        sys_rst <= 1;

        #4 sys_rst <= 0;
    end

    integer sim_count = 0;
    always @(posedge sys_clk) begin
        sim_count <= sim_count + 1;
        if (sim_count == 512)
            $finish();
    end


    // Generate Masters and Slaves
    //

    localparam [ADDR_WIDTH*SLAVE_COUNT-1:0] SLAVE_ADDRS = {
        32'h00000000,
        32'h00000400
    };
    localparam [ADDR_WIDTH*SLAVE_COUNT-1:0] SLAVE_MASKS = {
        32'((1<<10)-1),
        32'((1<<10)-1)
    };
    `WISHBONE_REGS_ARRAY(masters, MASTER_COUNT);
    `WISHBONE_REGS_ARRAY(slaves, SLAVE_COUNT);

    genvar gen_m;
    generate
    for (gen_m = 0; gen_m < MASTER_COUNT; gen_m++) begin : masters
        `WISHBONE_REGS(master);
        wishbone_master #(
            .ADDR_WIDTH(32),
            .DATA_WIDTH(32)
        ) master (
            .sys_clk(sys_clk),
            .sys_rst(sys_rst),
            `WISHBONE_PORT(wb, master)
        );
        always @(*) begin
            masters_cyc[gen_m] = master_cyc;
            masters_stb[gen_m] = master_stb;
            masters_we[gen_m] = master_we;
            masters_tag[3*gen_m +: 3] = master_tag;
            masters_sel[4*gen_m +: 4] = master_sel;
            masters_adr[32*gen_m +: 32] = master_adr;
            masters_mosi[32*gen_m +: 32] = master_mosi;
            master_miso = masters_miso[32*gen_m +: 32];
            master_ack = masters_ack[gen_m];
            master_err = masters_err[gen_m];
        end
    end

    genvar gen_s;
    for (gen_s = 0; gen_s < SLAVE_COUNT; gen_s++) begin : slaves
        `WISHBONE_REGS(slave);
        wishbone_slave #(
            .ADDR_WIDTH(32),
            .DATA_WIDTH(32),
            .ORIGIN(gen_s << 10),
            .LENGTH(1 << 10)
        ) slave (
            .sys_clk(sys_clk),
            .sys_rst(sys_rst),
            `WISHBONE_PORT(wb, slave)
        );
        assign slave_cyc = slaves_cyc[gen_s];
        assign slave_stb = slaves_stb[gen_s];
        assign slave_we = slaves_we[gen_s];
        assign slave_tag = slaves_tag[3*gen_s +: 3];
        assign slave_sel = slaves_sel[4*gen_s +: 4];
        assign slave_adr = slaves_adr[32*gen_s +: 32];
        assign slave_mosi = slaves_mosi[32*gen_s +: 32];
        assign slaves_miso[32*gen_s +: 32] = slave_miso;
        assign slaves_ack[gen_s] = slave_ack;
        assign slaves_err[gen_s] = slave_err;
    end
    endgenerate

    // Interconnect
    //
    wishbone_crossbar #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .MASTER_COUNT(MASTER_COUNT),
        .SLAVE_COUNT(SLAVE_COUNT),
        .SLAVE_ADDR(SLAVE_ADDRS),
        .SLAVE_MASK(SLAVE_MASKS)
    ) interconnect0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),

        .m_cyc ({masters_cyc }),
        .m_stb ({masters_stb }),
        .m_we  ({masters_we  }),
        .m_tag ({masters_tag }),
        .m_sel ({masters_sel }),
        .m_adr ({masters_adr }),
        .m_mosi({masters_mosi}),
        .m_miso({masters_miso}),
        .m_ack ({masters_ack }),
        .m_err ({masters_err }),

        .s_cyc ({slaves_cyc }),
        .s_stb ({slaves_stb }),
        .s_we  ({slaves_we  }),
        .s_tag ({slaves_tag }),
        .s_sel ({slaves_sel }),
        .s_adr ({slaves_adr }),
        .s_mosi({slaves_mosi}),
        .s_miso({slaves_miso}),
        .s_ack ({slaves_ack }),
        .s_err ({slaves_err })
    );
endmodule
