import os

# Paths
#

deps_dir = Dir("deps")


# Base Environment
#

env = Environment(
    ENV = {
        "PATH": os.environ.get("PATH", ""),
    }
)

if "TERM" in os.environ:
    env["ENV"]["TERM"] = os.environ["TERM"]


# Simulation Environment
#

iv_flags = [
    "-g2005-sv"
]

sim_env = env.Clone(
    tools = ["icarus"],
    toolpath = [deps_dir.Dir("scons-fpga")],

    IVFLAGS = iv_flags,
    VPATH = [
        Dir("rtl").srcnode()
    ]
)


# Simulations
#

SConscript(
    "sim/SConscript",
    variant_dir = "build/sim",
    duplicate = False,
    exports = {
        "env": sim_env
    }
)
