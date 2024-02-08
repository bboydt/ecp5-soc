// Macros for creating and using wishbone buses.
//
// Note that these macros omit syscon signals, they will need to be manually
// added.
//
// Use WISHBONE_WIRES for creating wires to connect a wishbone master and slave.
// Use WISHBONE_MASTER to declare inputs and outputs to a wishbone master.
// Use WISHBONE_SLAVE to declare inputs and outputs to a wishbone slave.
// Use WISHBONE_WIRES_ARRAY for creating wires to connect multiple wishbone masters and slaves.
// Use WISHBONE_MASTER_ARRAY to declare inputs and outputs to multiple wishbone masters.
// Use WISHBONE_SLAVE_ARRAY to declare inputs and outputs to multiple wishbone slaves.
// Use WISHBONE_PORT to connect to a module's wishbone signals.

`define WISHBONE_WIRES(PREFIX) \
    wire PREFIX``_cyc; \
    wire PREFIX``_stb; \
    wire PREFIX``_we; \
    wire [2:0] PREFIX``_tag; \
    wire [3:0] PREFIX``_sel; \
    wire [31:0] PREFIX``_adr; \
    wire [31:0] PREFIX``_mosi; \
    wire [31:0] PREFIX``_miso; \
    wire PREFIX``_ack; \
    wire PREFIX``_err

`define WISHBONE_REGS(PREFIX) \
    reg PREFIX``_cyc; \
    reg PREFIX``_stb; \
    reg PREFIX``_we; \
    reg [2:0] PREFIX``_tag; \
    reg [3:0] PREFIX``_sel; \
    reg [31:0] PREFIX``_adr; \
    reg [31:0] PREFIX``_mosi; \
    reg [31:0] PREFIX``_miso; \
    reg PREFIX``_ack; \
    reg PREFIX``_err

`define WISHBONE_MASTER(PREFIX) \
    output reg PREFIX``_cyc, \
    output reg PREFIX``_stb, \
    output reg PREFIX``_we, \
    output reg [2:0] PREFIX``_tag, \
    output reg [3:0] PREFIX``_sel, \
    output reg [31:0] PREFIX``_adr, \
    output reg [31:0] PREFIX``_mosi, \
    input [31:0] PREFIX``_miso, \
    input PREFIX``_ack, \
    input PREFIX``_err

`define WISHBONE_SLAVE(PREFIX) \
    input PREFIX``_cyc, \
    input PREFIX``_stb, \
    input PREFIX``_we, \
    input [2:0] PREFIX``_tag, \
    input [3:0] PREFIX``_sel, \
    input [31:0] PREFIX``_adr, \
    input [31:0] PREFIX``_mosi, \
    output reg [31:0] PREFIX``_miso, \
    output reg PREFIX``_ack, \
    output reg PREFIX``_err

`define WISHBONE_REGS_ARRAY(PREFIX, COUNT) \
    reg [COUNT-1:0] PREFIX``_cyc; \
    reg [COUNT-1:0] PREFIX``_stb; \
    reg [COUNT-1:0] PREFIX``_we; \
    reg [COUNT*3-1:0] PREFIX``_tag; \
    reg [COUNT*4-1:0] PREFIX``_sel; \
    reg [COUNT*32-1:0] PREFIX``_adr; \
    reg [COUNT*32-1:0] PREFIX``_mosi; \
    reg [COUNT*32-1:0] PREFIX``_miso; \
    reg [COUNT-1:0] PREFIX``_ack; \
    reg [COUNT-1:0] PREFIX``_err

`define WISHBONE_WIRES_ARRAY(PREFIX, COUNT) \
    wire [COUNT-1:0] PREFIX``_cyc; \
    wire [COUNT-1:0] PREFIX``_stb; \
    wire [COUNT-1:0] PREFIX``_we; \
    wire [COUNT*3-1:0] PREFIX``_tag; \
    wire [COUNT*4-1:0] PREFIX``_sel; \
    wire [COUNT*32-1:0] PREFIX``_adr; \
    wire [COUNT*32-1:0] PREFIX``_mosi; \
    wire [COUNT*32-1:0] PREFIX``_miso; \
    wire [COUNT-1:0] PREFIX``_ack; \
    wire [COUNT-1:0] PREFIX``_err

`define WISHBONE_MASTER_ARRAY(PREFIX, COUNT) \
    output reg [COUNT-1:0] PREFIX``_cyc, \
    output reg [COUNT-1:0] PREFIX``_stb, \
    output reg [COUNT-1:0] PREFIX``_we, \
    output reg [COUNT*3-1:0] PREFIX``_tag, \
    output reg [COUNT*4-1:0] PREFIX``_sel, \
    output reg [COUNT*32-1:0] PREFIX``_adr, \
    output reg [COUNT*32-1:0] PREFIX``_mosi, \
    input [COUNT*32-1:0] PREFIX``_miso, \
    input [COUNT-1:0] PREFIX``_ack, \
    input [COUNT-1:0] PREFIX``_err

`define WISHBONE_SLAVE_ARRAY(PREFIX, COUNT) \
    input reg [COUNT-1:0] PREFIX``_cyc, \
    input reg [COUNT-1:0] PREFIX``_stb, \
    input reg [COUNT-1:0] PREFIX``_we, \
    input reg [COUNT*3-1:0] PREFIX``_tag, \
    input reg [COUNT*4-1:0] PREFIX``_sel, \
    input reg [COUNT*32-1:0] PREFIX``_adr, \
    input reg [COUNT*32-1:0] PREFIX``_mosi, \
    output [COUNT*32-1:0] PREFIX``_miso, \
    output [COUNT-1:0] PREFIX``_ack, \
    output [COUNT-1:0] PREFIX``_err

`define WISHBONE_PORT(MODULE_PREFIX, INPUT_PREFIX) \
    .MODULE_PREFIX``_cyc(INPUT_PREFIX``_cyc), \
    .MODULE_PREFIX``_stb(INPUT_PREFIX``_stb), \
    .MODULE_PREFIX``_we(INPUT_PREFIX``_we), \
    .MODULE_PREFIX``_tag(INPUT_PREFIX``_tag), \
    .MODULE_PREFIX``_sel(INPUT_PREFIX``_sel), \
    .MODULE_PREFIX``_adr(INPUT_PREFIX``_adr), \
    .MODULE_PREFIX``_mosi(INPUT_PREFIX``_mosi), \
    .MODULE_PREFIX``_miso(INPUT_PREFIX``_miso), \
    .MODULE_PREFIX``_ack(INPUT_PREFIX``_ack), \
    .MODULE_PREFIX``_err(INPUT_PREFIX``_err)

`define WISHBONE_ZERO_REG(PREFIX) \
    PREFIX``_cyc <= 0; \
    PREFIX``_stb <= 0; \
    PREFIX``_we <= 0; \
    PREFIX``_tag <= 0; \
    PREFIX``_sel <= 0; \
    PREFIX``_adr <= 0; \
    PREFIX``_mosi <= 0; \
    PREFIX``_miso <= 0; \
    PREFIX``_ack <= 0; \
    PREFIX``_err <= 0

`define WISHBONE_ZERO_SLAVE(PREFIX) \
    PREFIX``_cyc <= 0; \
    PREFIX``_stb <= 0; \
    PREFIX``_we <= 0; \
    PREFIX``_tag <= 0; \
    PREFIX``_sel <= 0; \
    PREFIX``_adr <= 0; \
    PREFIX``_mosi <= 0

`define WISHBONE_CONNECT(MASTER_PREFIX, SLAVE_PREFIX) \
    SLAVE_PREFIX``_cyc <= MASTER_PREFIX``_cyc; \
    SLAVE_PREFIX``_stb <= MASTER_PREFIX``_stb; \
    SLAVE_PREFIX``_we <= MASTER_PREFIX``_we; \
    SLAVE_PREFIX``_tag <= MASTER_PREFIX``_tag; \
    SLAVE_PREFIX``_sel <= MASTER_PREFIX``_sel; \
    SLAVE_PREFIX``_adr <= MASTER_PREFIX``_adr; \
    SLAVE_PREFIX``_mosi <= MASTER_PREFIX``_mosi; \
    MASTER_PREFIX``_miso <= SLAVE_PREFIX``_miso; \
    MASTER_PREFIX``_ack <= SLAVE_PREFIX``_ack; \
    MASTER_PREFIX``_err <= SLAVE_PREFIX``_err

`define WISHBONE_ASSIGN(MASTER_PREFIX, SLAVE_PREFIX) \
    assign SLAVE_PREFIX``_cyc = MASTER_PREFIX``_cyc; \
    assign SLAVE_PREFIX``_stb = MASTER_PREFIX``_stb; \
    assign SLAVE_PREFIX``_we = MASTER_PREFIX``_we; \
    assign SLAVE_PREFIX``_tag = MASTER_PREFIX``_tag; \
    assign SLAVE_PREFIX``_sel = MASTER_PREFIX``_sel; \
    assign SLAVE_PREFIX``_adr = MASTER_PREFIX``_adr; \
    assign SLAVE_PREFIX``_mosi = MASTER_PREFIX``_mosi; \
    assign MASTER_PREFIX``_miso = SLAVE_PREFIX``_miso; \
    assign MASTER_PREFIX``_ack = SLAVE_PREFIX``_ack; \
    assign MASTER_PREFIX``_err = SLAVE_PREFIX``_err
