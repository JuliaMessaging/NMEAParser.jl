module NMEAParser

export NMEAData, parse_msg!, is_string_supported, update, nmea_parse
export NMEAString
export GGA, GSA, ZDA, GBS, GLL, GSV, RMC, VTG, DTM, PASHR, TWPOS, TWHPR

import Base.pop!
import Base.parse


include("utils.jl")
include("types.jl")
include("parse.jl")


end # module NMEAParser
