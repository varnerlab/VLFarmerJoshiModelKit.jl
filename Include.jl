# set paths for simulation -
const _PATH_TO_ROOT = pwd()
const _PATH_TO_SRC = joinpath(_PATH_TO_ROOT, "src")
const _PATH_TO_CONFIG = joinpath(_PATH_TO_ROOT, "config")

# load external packages -
using TOML
using Parameters

# load my codes -
include(joinpath(_PATH_TO_SRC, "VLTypes.jl"))
include(joinpath(_PATH_TO_SRC, "VLGameEngine.jl"))
include(joinpath(_PATH_TO_SRC, "VLFactory.jl"))