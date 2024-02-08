`timescale 10ns/1ns

`include "ecp5_soc/utils/wishbone.v"

module wishbone_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TAG_WIDTH = 3
) (
    input sys_clk,
    input sys_rst,

    `WISHBONE_MASTER(wb),

    input ready,
    output reg done,
    output reg failure
);
    localparam SEL_WIDTH = DATA_WIDTH / 8;

    initial begin
        done = 0;
        failure = 0;
    end

    always @(posedge sys_clk) begin
        if (ready & ~(wb_ack | wb_err)) begin
            wb_cyc <= 1;
            wb_stb <= 1;
            wb_tag <= 0;
            wb_sel <= 0;
            wb_adr <= 0;
            wb_mosi <= 0;

            done <= 0;
            failure <= 0;
        end else begin
            wb_cyc <= 0;
            wb_stb <= 0;
            wb_tag <= 0;
            wb_sel <= 0;
            wb_adr <= 0;
            wb_mosi <= 0;

            done <= 1;
            failure <= wb_err;
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

    string output_path;
    initial begin
        $display("Wishbone Testbench");
        if ($value$plusargs("output=%s", output_path)) begin
            $dumpfile(output_path);
            $dumpvars(0, testbench);
        end
    end

    // Master
    //
    
    reg ready;
    wire done;
    wire failure;

    `WISHBONE_REGS(m0);
    wishbone_master #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .TAG_WIDTH(3)
    ) m0 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        `WISHBONE_PORT(wb, m0),

        .ready(ready),
        .done(done),
        .failure(failure)
    );

    // Slave
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

    always @(*) begin
        s0_cyc  = m0_cyc;
        s0_stb  = m0_stb;
        s0_we   = m0_we;
        s0_tag  = m0_tag;
        s0_sel  = m0_sel;
        s0_adr  = m0_adr;
        s0_mosi = m0_mosi;

        m0_miso = s0_miso;
        m0_ack  = s0_ack;
        m0_err  = s0_err;
    end

    // System Control
    //
    
    reg sys_clk;
    reg sys_rst;

    initial begin
        ready = 0;
        sys_clk = 0;
        sys_rst = 1;
        #2 sys_rst = 0;
        ready = 1;
        #98 $finish();
    end

    always @(posedge done) begin
        #2 ready <= 0;
        #10 ready <= 1;
    end

    always #1 sys_clk = !sys_clk;
    

endmodule
