`timescale 10ns/1ns

`include "ecp5_soc/utils/wishbone.v"
`include "ecp5_soc/package/wishbone_crossbar.v"

module wishbone_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TAG_WIDTH = 3
) (
    input sys_clk,
    input sys_rst,

    `WISHBONE_MASTER(wb),

    input ready,
    input [ADDR_WIDTH-1:0] adr
);
    localparam SEL_WIDTH = DATA_WIDTH / 8;

    always @(posedge sys_clk) begin
        if (ready) begin
            wb_cyc <= 1;
            wb_stb <= 1;
            wb_we <= 0;
            wb_tag <= 0;
            wb_sel <= 0;
            wb_adr <= adr;
            wb_mosi <= 0;
        end else begin
            wb_cyc <= 0;
            wb_stb <= 0;
            wb_we <= 0;
            wb_tag <= 0;
            wb_sel <= 0;
            wb_adr <= 0;
            wb_mosi <= 0;
        end
    end

endmodule

module wishbone_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TAG_WIDTH = 3
) (
    input sys_clk,
    input sys_rst,

    `WISHBONE_SLAVE(wb)
);

    always @(posedge sys_clk) begin
        if (wb_stb) begin
            wb_miso <= 0;
            wb_ack <= 1;
            wb_err <= 0;
        end else begin
            wb_miso <= 0;
            wb_ack <= 0;
            wb_err <= 0;
        end
    end

endmodule

module testbench ();

    // Write to VCD file
    //

    string output_path;
    initial begin
        $display("Wishbone Testbench");
        if ($value$plusargs("output=%s", output_path)) begin
            $dumpfile(output_path);
            $dumpvars(0, testbench);
        end
    end

    // System Control Signals
    //

    reg sys_clk;
    reg sys_rst;
    reg ready;
    reg [31:0] adr;

    initial begin
        adr = 0;
        sys_clk = 0;
        sys_rst = 0;
        ready = 0;
        #100 $finish();
    end

    always #1 sys_clk = ~sys_clk;
    always #10 ready = ~ready;
    always #20 adr = adr ^ 32'h4000;

    // Masters
    // 

    `WISHBONE_WIRES(m0);
    wishbone_master #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .TAG_WIDTH(3)
    ) m0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        `WISHBONE_PORT(wb, m0),
        .ready(ready),
        .adr(adr)
    );

    // Slaves
    //

    `WISHBONE_REGS(s0);
    wishbone_slave #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .TAG_WIDTH(3)
    ) s0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        `WISHBONE_PORT(wb, s0)
    );

    `WISHBONE_REGS(s1);
    wishbone_slave #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .TAG_WIDTH(3)
    ) s1 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        `WISHBONE_PORT(wb, s1)
    );

    // Interconnect
    //

    wishbone_crossbar #(
        .NM(1),
        .NS(2),
        .SA({32'h0000, 32'h4000}),
        .SM({32'h3fff, 32'h3fff})
    ) wbx0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),

        .masters_cyc ({m0_cyc }),
        .masters_stb ({m0_stb }),
        .masters_we  ({m0_we  }),
        .masters_tag ({m0_tag }),
        .masters_sel ({m0_sel }),
        .masters_adr ({m0_adr }),
        .masters_mosi({m0_mosi}),
        .masters_miso({m0_miso}),
        .masters_ack ({m0_ack }),
        .masters_err ({m0_err }),

        .slaves_cyc ({s0_cyc , s1_cyc }),
        .slaves_stb ({s0_stb , s1_stb }),
        .slaves_we  ({s0_we  , s1_we  }),
        .slaves_tag ({s0_tag , s1_tag }),
        .slaves_sel ({s0_sel , s1_sel }),
        .slaves_adr ({s0_adr , s1_adr }),
        .slaves_mosi({s0_mosi, s1_mosi}),
        .slaves_miso({s0_miso, s1_miso}),
        .slaves_ack ({s0_ack , s1_ack }),
        .slaves_err ({s0_err , s1_err })
    );

endmodule
