// ROM
//
// Make sure LENGTH is a multiple of 16KB

module rom #(
    parameter ADDR_WIDTH = 32,
    parameter LENGTH = 16384,
    parameter INIT_FILE
) (
    input sys_clk,
    input sys_rst,

    `WISHBONE_SLAVE(wb)
);
    localparam DATA_LENGTH = LENGTH / 4;
    localparam MIN_ADDR_WIDTH = $clog2(DATA_LENGTH);

    reg [31:0] data[(LENGTH/4)-1:0];
    initial $readmemh(INIT_FILE, data, 0, DATA_LENGTH - 1);

    integer b;
    always @(posedge sys_clk) begin
        if (wb_cyc & wb_stb) begin
            if (~wb_ack) begin
                if (wb_we) begin
                    wb_ack <= 0;
                    wb_err <= 1;
                end else begin
                    wb_miso <= {
                        data[MIN_ADDR_WIDTH'(wb_adr[ADDR_WIDTH-1:2])][7:0],
                        data[MIN_ADDR_WIDTH'(wb_adr[ADDR_WIDTH-1:2])][15:8],
                        data[MIN_ADDR_WIDTH'(wb_adr[ADDR_WIDTH-1:2])][23:16],
                        data[MIN_ADDR_WIDTH'(wb_adr[ADDR_WIDTH-1:2])][31:24]
                    };
                    wb_ack <= 1;
                    wb_err <= 0;
                end
            end
        end else begin
            wb_ack <= 0;
            wb_err <= 0;
        end
    end

endmodule
