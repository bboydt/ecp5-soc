# Builds SoC bitstream
#

import os

# Flags
#

ghdl_flags = [
    "--std=08",
]

yosys_flags = [
#    "-q",
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

# Paths
#

neorv32_build_dir = Dir("build/neorv32")

# Environment
#

env = Environment(
    tools = ["yosys", "nextpnr", "trellis", "icarus"],
    toolpath = ["deps/scons-fpga"],

    ENV = {
        "PATH": os.environ.get("PATH", ""),
        "TERM": os.environ.get("TERM", ""),
    },

    GHDL = "ghdl",

    IVFLAGS = iv_flags,

    VPATH = [
        Dir("rtl").srcnode(),
        neorv32_build_dir.srcnode()
    ],

    GHDL_FLAGS = ghdl_flags,
    YOSYSFLAGS = yosys_flags,
    PNRFLAGS = nextpnr_flags,
    ECPPACKFLAGS = ecppack_flags,
)

# Board
#

board_dir = Dir("boards/butterstick")
board_pcf = board_dir.File("r1_0.pcf")
board_top = board_dir.File("top.v")

env.Append(
    VPATH = [
        board_dir.srcnode(),
    ],

    PNRFLAGS = [
        f"--lpf={board_pcf}",
    ]
)

# SConscripts
#

SConscript(
    "deps/SConscript-neorv32",
    variant_dir = neorv32_build_dir.path,
    duplicate = False,
    exports = { "env": env }
)

SConscript(
    "rtl/SConscript",
    variant_dir = "build/rtl",
    duplicate = False,
    exports = { "env": env }
)

SConscript(
    "boards/butterstick/SConscript",
    variant_dir = "build/butterstick",
    duplicate = False,
    exports = { "env": env }
)

