// Wishbone Bus Arbitration Logic
//
// All slave masks must be one less than a power of two.
// i.e. A slave with 8KB of address space would have a mask of 0x1FFF.
// And their addresses must be a power of two.

module arbitrator #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter MASTER_COUNT = 2,
    parameter SLAVE_COUNT = 4,

    parameter [SLAVE_COUNT-1:0][ADDR_WIDTH-1:0] SLAVE_ADDR = 0,
    parameter [SLAVE_COUNT-1:0][ADDR_WIDTH-1:0] SLAVE_MASK = 0
) (
    // syscon
    input sys_clk,
    input sys_rst,

    // master ports
    input [MASTER_COUNT-1:0] master_cyc,
    input [MASTER_COUNT-1:0] master_stb,
    input [MASTER_COUNT-1:0] master_we,
    input [MASTER_COUNT-1:0][2:0] master_tag,
    input [MASTER_COUNT-1:0][DATA_WIDTH/8-1:0] master_sel,
    input [MASTER_COUNT-1:0][ADDR_WIDTH-1:0] master_adr,
    input [MASTER_COUNT-1:0][DATA_WIDTH-1:0] master_mosi,
    output reg [MASTER_COUNT-1:0][DATA_WIDTH-1:0] master_miso,
    output reg [MASTER_COUNT-1:0] master_ack,
    output reg [MASTER_COUNT-1:0] master_err,

    // slave ports
    output reg [SLAVE_COUNT-1:0] slave_cyc,
    output reg [SLAVE_COUNT-1:0] slave_stb,
    output reg [SLAVE_COUNT-1:0] slave_we,
    output reg [SLAVE_COUNT-1:0][2:0] slave_tag,
    output reg [SLAVE_COUNT-1:0][DATA_WIDTH/8-1:0] slave_sel,
    output reg [SLAVE_COUNT-1:0][ADDR_WIDTH-1:0] slave_adr,
    output reg [SLAVE_COUNT-1:0][DATA_WIDTH-1:0] slave_mosi,
    input [SLAVE_COUNT-1:0][DATA_WIDTH-1:0] slave_miso,
    input [SLAVE_COUNT-1:0] slave_ack,
    input [SLAVE_COUNT-1:0] slave_err
);

    // Decode master requests
    //
    wire [MASTER_COUNT-1:0][SLAVE_COUNT-1:0] slave_req;
    genvar gen_m;
    genvar gen_s;
    generate
        for (gen_m = 0; gen_m < MASTER_COUNT; gen_m++) begin
            for (gen_s = 0; gen_s < SLAVE_COUNT; gen_s++) begin
                assign slave_req[gen_m][gen_s] = ((master_adr[gen_m] ^ SLAVE_ADDR[gen_s] & ~SLAVE_MASK[gen_s]) == 0);
            end
        end
    endgenerate

    // Handle requests
    //
    localparam MASTER_ADDR_WIDTH = $clog2(MASTER_COUNT);
    localparam SLAVE_ADDR_WIDTH = $clog2(SLAVE_COUNT);
    reg [MASTER_COUNT-1:0][SLAVE_ADDR_WIDTH-1:0] slave_select;
    reg [SLAVE_COUNT-1:0][MASTER_ADDR_WIDTH-1:0] master_select;
    reg [MASTER_COUNT-1:0] master_busy;
    reg [SLAVE_COUNT-1:0] slave_busy;
    integer m;
    integer s;
    always @(posedge sys_clk) begin
    
        // Grant master requests
        //
        for (m = 0; m < MASTER_COUNT; m++) begin
            if (master_cyc[m] & master_stb[m]) begin
                for (s = 0; s < SLAVE_COUNT; s++) begin
                    if (!slave_busy[s] && slave_req[m][s]) begin
                        master_busy[m] <= 1'b1;
                        master_select[s] <= MASTER_ADDR_WIDTH'(m);
                        slave_busy[s] <= 1'b1;
                        slave_select[m] <= SLAVE_ADDR_WIDTH'(s);
                    end
                end
            end
        end

        // Look for any busy slaves who no longer have an active master
        //
        // Note on the order of this:
        // This is done after granting master requests so the slaves
        // can observe stb go low.
        //
        for (s = 0; s < MASTER_COUNT; s++) begin
            if (slave_busy[s] & ~master_stb[master_select[s]]) begin
                slave_busy[s] <= 1'b0;
                master_busy[master_select[s]] <= 1'b0;
            end
        end

        // Connect masters to slaves and vice versa
        //
        for (m = 0; m < MASTER_COUNT; m++) begin
            if (master_busy[m]) begin
                master_miso[m] <= slave_miso[slave_select[m]];
                master_ack[m] <= slave_ack[slave_select[m]];
                master_err[m] <= slave_err[slave_select[m]];
            end else begin
                master_miso[m] <= 0;
                master_ack[m] <= 0;
                master_err[m] <= 0;
            end
        end

        for (s = 0; s < SLAVE_COUNT; s++) begin
            if (slave_busy[s]) begin
                slave_cyc[s] <= master_cyc[master_select[s]];
                slave_stb[s] <= master_stb[master_select[s]];
                slave_we[s] <= master_we[master_select[s]];
                slave_tag[s] <= master_tag[master_select[s]];
                slave_sel[s] <= master_sel[master_select[s]];
                slave_adr[s] <= master_adr[master_select[s]];
                slave_mosi[s] <= master_mosi[master_select[s]];
            end else begin
                slave_cyc[s] <= 0;
                slave_stb[s] <= 0;
                slave_we[s] <= 0;
                slave_tag[s] <= 0;
                slave_sel[s] <= 0;
                slave_adr[s] <= 0;
                slave_mosi[s] <= 0;
            end
        end
    end

endmodule
