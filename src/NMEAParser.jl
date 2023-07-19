module NMEAParser

export NMEAData, parse_msg!
export GGA, GSA, ZDA, GBS, GLL, GSV, RMC, VTG, DTM, PASHR, TWPOS


include("utils.jl")
include("types.jl")
include("parse.jl")

"""
    NMEAData()

A mutable struct that stores the last parsed NMEA messages of different types.

# Fields
- `last_GGA::Union{Nothing, GGA}`: the last GGA message parsed, or nothing if none
- `last_RMC::Union{Nothing, RMC}`: the last RMC message parsed, or nothing if none
- `last_GSA::Union{Nothing, GSA}`: the last GSA message parsed, or nothing if none
- `last_GSV::Union{Nothing, GSV}`: the last GSV message parsed, or nothing if none
- `last_GBS::Union{Nothing, GBS}`: the last GBS message parsed, or nothing if none
- `last_VTG::Union{Nothing, VTG}`: the last VTG message parsed, or nothing if none
- `last_GLL::Union{Nothing, GLL}`: the last GLL message parsed, or nothing if none
- `last_ZDA::Union{Nothing, ZDA}`: the last ZDA message parsed, or nothing if none
- `last_DTM::Union{Nothing, DTM}`: the last DTM message parsed, or nothing if none
- `last_PASHR::Union{Nothing, PASHR}`: the last PASHR message parsed, or nothing if none
- `last_TWPOS::Union{Nothing, TWPOS}`: the last TWPOS message parsed, or nothing if none
"""
mutable struct NMEAData
    last_GGA::Union{Nothing, GGA}
    last_RMC::Union{Nothing, RMC}
    last_GSA::Union{Nothing, GSA}
    last_GSV::Union{Nothing, GSV}
    last_GBS::Union{Nothing, GBS}
    last_VTG::Union{Nothing, VTG}
    last_GLL::Union{Nothing, GLL}
    last_ZDA::Union{Nothing, ZDA}
    last_DTM::Union{Nothing, DTM}
    last_PASHR::Union{Nothing, PASHR}
    last_TWPOS::Union{Nothing, TWPOS}

    function NMEAData()
        new(nothing, nothing, nothing,
            nothing, nothing, nothing, nothing,
            nothing, nothing, nothing, nothing)
    end # constructor NMEAData
end # type NMEAData

"""
    update!(s::NMEAData, msg)

Update the corresponding field of `s` with the given NMEA message `msg`.

# Arguments
- `s::NMEAData`: the NMEA data struct to be updated
- `msg`: an NMEA message of type GGA, RMC, GSA, GSV, GBS, VTG, GLL, ZDA, DTM, PASHR or TWPOS

"""
update!(s::NMEAData, msg::GGA) = s.last_GGA = msg
update!(s::NMEAData, msg::RMC) = s.last_RMC = msg
update!(s::NMEAData, msg::GSA) = s.last_GSA = msg
update!(s::NMEAData, msg::GSV) = s.last_GSV = msg
update!(s::NMEAData, msg::GBS) = s.last_GBS = msg
update!(s::NMEAData, msg::VTG) = s.last_VTG = msg
update!(s::NMEAData, msg::GLL) = s.last_GLL = msg
update!(s::NMEAData, msg::ZDA) = s.last_ZDA = msg
update!(s::NMEAData, msg::DTM) = s.last_DTM = msg
update!(s::NMEAData, msg::PASHR) = s.last_PASHR = msg
update!(s::NMEAData, msg::TWPOS) = s.last_TWPOS = msg

"""
    parse_msg!(s::NMEAData, line::AbstractString)

Parse a line of NMEA 0183 data and update the state of an NMEAData object.

Parameters
----------
s : NMEAData
    An object that stores the parsed data from NMEA messages.
line : AbstractString
    A string that contains a valid NMEA 0183 message.

Returns
-------
DataType
    The type of the parsed message, or Nothing if the message is not supported.

Throws
------
ArgumentError
    If the line is not a valid NMEA 0183 message.

# Example
```
s = NMEAData()

julia> d = [raw"$GPRMC,154925.820,A,5209.732,N,00600.240,E,001.9,059.8,040123,000.0,W*7E",
       raw"$GPGGA,154925.920,5209.732,N,00600.240,E,1,12,1.0,0.0,M,0.0,M,,*63",
       raw"$GPGSA,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,1.0,1.0*30",
       raw"$GPRMC,154925.920,A,5209.732,N,00600.240,E,001.9,059.8,040123,000.0,W*7F"]
4-element Vector{String}:
 "\$GPRMC,154925.820,A,5209.732,N,00600.240,E,001.9,059.8,040123,000.0,W*7E"
 "\$GPGGA,154925.920,5209.732,N,00600.240,E,1,12,1.0,0.0,M,0.0,M,,*63"
 "\$GPGSA,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,1.0,1.0*30"
 "\$GPRMC,154925.920,A,5209.732,N,00600.240,E,001.9,059.8,040123,000.0,W*7F"

 julia> for str in d
            msg_type = parse_msg!(s, str)
            println(msg_type)
        end
 RMC
 GGA
 GSA
 RMC

 julia> s.last_RMC
 RMC("GPS", 56965.92, true, 52.1622, 6.004, 1.9, 59.8, "04", "01", "23", -0.0, 'A', true)

 julia> s.last_GGA
 GGA("GPS", 56965.92, 52.1622, 6.004, "GPS (SPS)", 12, 1.0, 0.0, 0.0, 0.0, 0, true)
```
"""
function parse_msg!(s::NMEAData, line::AbstractString)
    try
        message = parse(line)

        update!(s, message)

        return message |> typeof
    catch err
        if isa(err, ArgumentError)
            mtype = split(line, ',')[1]
            @warn "$mtype is not a supported NMEA string. skipping."
            return Nothing
        end
        rethrow(err)
    end
end # function parse_msg!


end # module NMEAParser
