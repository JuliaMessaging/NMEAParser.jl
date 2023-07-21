module NMEAParser

export NMEAData, parse_msg!
export GGA, GSA, ZDA, GBS, GLL, GSV, RMC, VTG, DTM, PASHR, TWPOS

import Base.pop!
import Base.parse


include("utils.jl")
include("types.jl")
include("parse.jl")


end # module NMEAParser
