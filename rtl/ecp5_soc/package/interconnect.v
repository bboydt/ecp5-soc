

module wishbone_crossbar #(
    parameter MASTER_COUNT = 2,
    parameter SLAVE_COUNT = 2,

    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TAG_WIDTH = 3,

    parameter [SLAVE_COUNT*ADDR_WIDTH-1:0] SLAVE_ADDR = 0,
    parameter [SLAVE_COUNT*ADDR_WIDTH-1:0] SLAVE_MASK = 0
) (
    input sys_clk,
    input sys_rst,

    input [MASTER_COUNT-1:0] m_cyc,
    input [MASTER_COUNT-1:0] m_stb,
    input [MASTER_COUNT-1:0] m_we,
    input [MASTER_COUNT*TAG_WIDTH-1:0] m_tag,
    input [MASTER_COUNT*DATA_WIDTH/8-1:0] m_sel,
    input [MASTER_COUNT*ADDR_WIDTH-1:0] m_adr,
    input [MASTER_COUNT*DATA_WIDTH-1:0] m_mosi,
    output reg [MASTER_COUNT*DATA_WIDTH-1:0] m_miso,
    output reg [MASTER_COUNT-1:0] m_ack,
    output reg [MASTER_COUNT-1:0] m_err,

    output reg [SLAVE_COUNT-1:0] s_cyc,
    output reg [SLAVE_COUNT-1:0] s_stb,
    output reg [SLAVE_COUNT-1:0] s_we,
    output reg [SLAVE_COUNT*TAG_WIDTH-1:0] s_tag,
    output reg [SLAVE_COUNT*DATA_WIDTH/8-1:0] s_sel,
    output reg [SLAVE_COUNT*ADDR_WIDTH-1:0] s_adr,
    output reg [SLAVE_COUNT*DATA_WIDTH-1:0] s_mosi,
    input [SLAVE_COUNT*DATA_WIDTH-1:0] s_miso,
    input [SLAVE_COUNT-1:0] s_ack,
    input [SLAVE_COUNT-1:0] s_err
);

    localparam SEL_WIDTH = DATA_WIDTH/8;

    reg [MASTER_COUNT*SLAVE_COUNT-1:0] slave_req;
    reg [SLAVE_COUNT-1:0] slave_busy;
    reg [MASTER_COUNT*SLAVE_COUNT-1:0] slave_grant;

    initial begin
        slave_req = 0;
        slave_busy = 0;
        slave_grant = 0;

        m_miso = 0;
        m_ack = 0;
        m_err = 0;

        s_cyc = 0;
        s_stb = 0;
        s_we = 0;
        s_tag = 0;
        s_sel = 0;
        s_adr = 0;
        s_mosi = 0;
    end

    genvar M, S;
    integer m, s;

    // Decode addresses
    //
    always @(*) begin
        for (m = 0; m < MASTER_COUNT; m++) begin
            slave_req[SLAVE_COUNT*m +: SLAVE_COUNT] = 0;
            for (s = 0; s < SLAVE_COUNT; s++) begin
                // and the award for longest line in history goes too...
                slave_req[SLAVE_COUNT*m+s] = m_cyc[m] & (((m_adr[ADDR_WIDTH*m +: ADDR_WIDTH] ^ SLAVE_ADDR[ADDR_WIDTH*s +: ADDR_WIDTH]) & ~SLAVE_MASK[ADDR_WIDTH*s +: ADDR_WIDTH]) == 0);
            end
        end
    end

    // Grant slaves to masters
    //
    always @(*) begin
        for (m = 0; m < MASTER_COUNT; m++) begin
            for (s = 0; s < SLAVE_COUNT; s++) begin
                if (~slave_busy[s] & slave_req[SLAVE_COUNT*m + s]) begin
                    slave_busy[s] = 1'b1;
                    slave_grant[SLAVE_COUNT*m+s] = 1'b1;
                end
            end
        end
    end

    // Connect masters to slaves
    //
    always @(*) begin
        for (m = 0; m < MASTER_COUNT; m++) begin
            for (s = 0; s < SLAVE_COUNT; s++) begin
                if (slave_grant[SLAVE_COUNT*m+s]) begin
                    s_cyc[s] = m_cyc[m];
                    s_stb[s] = m_stb[m];
                    s_we[s] = m_we[m];
                    s_tag[TAG_WIDTH*s +: TAG_WIDTH] = m_tag[TAG_WIDTH*m +: TAG_WIDTH];
                    s_sel[SEL_WIDTH*s +: SEL_WIDTH] = m_sel[SEL_WIDTH*m +: SEL_WIDTH];
                    s_adr[ADDR_WIDTH*s +: ADDR_WIDTH] = m_adr[ADDR_WIDTH*m +: ADDR_WIDTH];
                    s_mosi[DATA_WIDTH*s +: DATA_WIDTH] = m_mosi[DATA_WIDTH*m +: DATA_WIDTH];
                    m_miso[DATA_WIDTH*m +: DATA_WIDTH] = s_miso[DATA_WIDTH*s +: DATA_WIDTH];
                    m_ack[m] = s_ack[s];
                    m_err[m] = s_err[s];
                end
            end
        end
    end

    // Clear connects
    //
    always @(posedge sys_clk) begin
        for (m = 0; m < MASTER_COUNT; m++) begin
            for (s = 0; s < SLAVE_COUNT; s++) begin
                if (slave_grant[SLAVE_COUNT*m+s] & ~m_cyc[m]) begin
                    slave_busy[s] <= 1'b0;
                    slave_grant[SLAVE_COUNT*m+s] <= 1'b0;

                    m_miso[DATA_WIDTH*m +: DATA_WIDTH] <= 0;
                    m_ack[m] <= 1'b0;
                    m_err[m] <= 1'b0;

                    s_cyc[s] <= 1'b0;
                    s_stb[s] <= 1'b0;
                    s_we[s] <= 1'b0;
                    s_tag[TAG_WIDTH*s +: TAG_WIDTH] <= 0;
                    s_sel[SEL_WIDTH*s +: SEL_WIDTH] <= 0;
                    s_adr[ADDR_WIDTH*s +: ADDR_WIDTH] <= 0;
                    s_mosi[DATA_WIDTH*s +: DATA_WIDTH] <= 0;
                end
            end
        end
    end

endmodule
