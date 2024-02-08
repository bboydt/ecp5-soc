module wishbone_crossbar #(
    // number of masters
    parameter NM = 3,
    // number of slaves
    parameter NS = 3,
    // data width
    parameter DW = 32,
    // address width
    parameter AW = 32,
    // tag width
    parameter TW = 3,
    // sel width
    parameter SW = DW / 8,
    // start address of slaves
    parameter [NS*AW-1:0] SA = 0,
    // address masks of slaves (masks out offset bits)
    parameter [NS*AW-1:0] SM = 0
) (
    input wire sys_clk,
    input wire sys_rst,

    input wire [NM-1:0] masters_cyc,
    input wire [NM-1:0] masters_stb,
    input wire [NM-1:0] masters_we,
    input wire [NM*TW-1:0] masters_tag,
    input wire [NM*SW-1:0] masters_sel,
    input wire [NM*AW-1:0] masters_adr,
    input wire [NM*DW-1:0] masters_mosi,
    output reg [NM*DW-1:0] masters_miso,
    output reg [NM-1:0] masters_ack,
    output reg [NM-1:0] masters_err,

    output reg [NS-1:0] slaves_cyc,
    output reg [NS-1:0] slaves_stb,
    output reg [NS-1:0] slaves_we,
    output reg [NS*TW-1:0] slaves_tag,
    output reg [NS*SW-1:0] slaves_sel,
    output reg [NS*AW-1:0] slaves_adr,
    output reg [NS*DW-1:0] slaves_mosi,
    input wire [NS*DW-1:0] slaves_miso,
    input wire [NS-1:0] slaves_ack,
    input wire [NS-1:0] slaves_err
);

    integer m, s; // used in for loops

    reg [NM-1:0] master_connected;
    reg [NS-1:0] slave_connected;

    reg [NM*NS-1:0] grant; // access with index = m*NS+s

    // Grant Logic
    //
    always @(*) begin
        master_connected = 0;
        slave_connected = 0;
        for (m = 0; m < NM; m++) begin
            for (s = 0; s < NS; s++) begin
                if (masters_cyc[m] & ((SA[s*AW+:AW] ^ masters_adr[m*AW+:AW]) & ~SM[s*AW+:AW]) == 0) begin
                    grant[m*NS+s] = 1;
                    master_connected[m] = master_connected[m] | 1'b1;
                    slave_connected[s] = slave_connected[s] | 1'b1;
                end else begin
                    grant[m*NS+s] = 0;
                end
            end
        end
    end
    
    // Connection Logic
    //
    always @(*) begin
        for (m = 0; m < NM; m++) begin
            if (master_connected[m]) begin
                // connect master inputs to granted slave
                for (s = 0; s < NS; s++) begin
                    if (grant[m*NS+s]) begin
                        masters_miso[m*DW+:DW] = slaves_miso[s*DW+:DW];
                        masters_ack[m] = slaves_ack[s];
                        masters_err[m] = slaves_err[s];
                    end
                end
            end else begin
                // zero master inputs when not connected
                masters_miso[m*DW +: DW] = 0;
                masters_ack[m] = 0;
                masters_err[m] = 0;
            end
        end

        for (s = 0; s < NS; s++) begin
            if (slave_connected[s]) begin
                // connect slave inputs to master it is granted to
                for (m = 0; m < NM; m++) begin
                    if (grant[m*NS+s]) begin
                        slaves_cyc[s] = masters_cyc[m];
                        slaves_stb[s] = masters_stb[m];
                        slaves_we[s] = masters_we[m];
                        slaves_tag[s*TW+:TW] = masters_tag[m*TW+:TW];
                        slaves_sel[s*SW+:SW] = masters_sel[m*SW+:SW];
                        slaves_adr[s*AW+:AW] = masters_adr[m*AW+:AW];
                        slaves_mosi[s*DW+:DW] = masters_mosi[m*DW+:DW];
                    end
                end
            end else begin
                // zero slave inputs when not connected
                slaves_cyc[s] = 0;
                slaves_stb[s] = 0;
                slaves_we[s] = 0;
                slaves_tag[s*TW+:TW] = 0;
                slaves_sel[s*SW+:SW] = 0;
                slaves_adr[s*AW+:AW] = 0;
                slaves_mosi[s*DW+:DW] = 0;
            end
        end
    end

endmodule
