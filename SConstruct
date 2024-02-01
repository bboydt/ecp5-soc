# Builds SoC bitstream
#

import os

neorv32_build_dir = Dir("build/neorv32")

env = Environment(
    tools = ["yosys", "nextpnr", "trellis", "icarus"],
    toolpath = ["deps/scons-fpga"],

    ENV = {
        "PATH": os.environ.get("PATH", ""),
        "TERM": os.environ.get("TERM", ""),
    },

    GHDL = "ghdl",

    IVFLAGS = "-g2005-sv",

    VPATH = [
        Dir("rtl").srcnode(),
        neorv32_build_dir.srcnode()
    ],
)

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

