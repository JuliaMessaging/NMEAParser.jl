module NMEAParser

export NMEAData, parse_msg!, is_string_supported, update, nmea_parse
export NMEAString
export GGA, GSA, ZDA, GBS, GLL, GSV, GST, RMC, VTG, DTM
export PASHR, WPOS, WHPR, WVCT, WPLS, WWHE, WHPR, ACC, GYR

include("utils.jl")
include("types.jl")
include("parse.jl")


end # module NMEAParser
