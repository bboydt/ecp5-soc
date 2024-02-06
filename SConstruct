# Builds SoC bitstream
#

import os

# Flags
#

ghdl_flags = [
    "--std=08",
]

yosys_flags = [
    "-q",
]

nextpnr_flags = [ 
#    "-q",
    "--um5g-85k",
    "--speed=8", 
    "--package=CABGA381",
]

ecppack_flags = [
    "--compress",
    "--freq=38.8",
]

iv_flags = [
    "-g2005-sv",
]

v_flags = [
    "-sv"
]

# Paths
#

neorv32_dir = Dir("deps/neorv32")
neorv32_build_dir = Dir("build/neorv32")

# Environment
#

# @todo move address and length stuff to a file so we can add it as a source
width = 32
rom0_length = 16<<10
bram0_length = 16<<10

env = Environment(
    tools = ["yosys", "nextpnr", "trellis", "icarus"],
    toolpath = ["deps/scons-fpga"],

    ENV = {
        "PATH": os.environ.get("PATH", ""),
        "TERM": os.environ.get("TERM", ""),
    },

    GHDL = "ghdl",

    IVFLAGS = iv_flags,
    
    VFLAGS = v_flags,

    VPATH = [
        Dir("rtl").srcnode(),
    ],

    VDEFINES = {
        "ROM0_LENGTH": rom0_length,
        "BRAM0_LENGTH": bram0_length
    },

    GHDL_FLAGS = ghdl_flags,
    YOSYSFLAGS = yosys_flags,
    PNRFLAGS = nextpnr_flags,
    ECPPACKFLAGS = ecppack_flags,
)
