`include "ecp5_soc/utils/wishbone.v"
`include "ecp5_soc/cores/rom.v"

module testbench (
);

    reg sys_clk = 0;
    reg sys_rst = 0;
    reg [31:0] cnt = 0;
    reg ready = 0;

    integer i;
    integer count = 0;
    initial begin
        $display(":: rom_tb.v ::");

        $dumpfile("rom.vcd");
        $dumpvars(0, testbench);
        
        `WISHBONE_ZERO_REG(tb);
        `WISHBONE_ZERO_SLAVE(dut);
    end


    // Mock Master
    //

    `WISHBONE_REGS(tb);
    always @(posedge sys_clk) begin

        if (~tb_stb) begin
            tb_cyc <= 1;
            tb_stb <= 1;
            tb_adr <= tb_adr + 4;
            count = count + 1;
        end else begin
            if (dut_ack) begin
                tb_cyc <= 0;
                tb_stb <= 0;
            end else if (dut_err) begin
                $display("[ERROR] Bus Error");
            end
        end
    end

    // DUT
    //

    `WISHBONE_REGS(dut);
    rom #(
        .ADDR_WIDTH(32),
        .LENGTH(2048),
        .INIT_FILE("sim/rom.init")
    ) dut (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        `WISHBONE_PORT(wb, dut)
    );

    // Test
    //

    always #1 sys_clk = ~sys_clk;

    always @(*) begin
        `WISHBONE_CONNECT(tb, dut);
    end

    always @(count) begin
        if (count == 2048/4)
            $finish();
    end

endmodule;

