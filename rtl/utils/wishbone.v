// Macros for creating and using wishbone buses.
//
// Note that these macros omit syscon signals, they will need to be manually
// added.
//
// Use WISHBONE_WIRES for creating wires to connect two modules.
// Use WISHBONE_MASTER to declare inputs and outputs to a wishbone master.
// Use WISHBONE_SLAVE to declare inputs and outputs to a wishbone master.
// Use WISHBONE_PORT to connect to a module's wishbone signals.
// Use WISHBONE_ADDR_RANGE to declare parameters for a wishbone slave's
// address range.

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

// @todo add assertion that LENGTH must be a power of two
`define WISHBONE_ADDR_RANGE(WIDTH, SLAVE, ORIGIN, LENGTH) \
    integer [WIDTH-1:0] SLAVE``_ADDR = WIDTH'(ORIGIN); \
    integer [WIDTH-1:0] SLAVE``_MASK = WIDTH'(LENGTH - 1)

