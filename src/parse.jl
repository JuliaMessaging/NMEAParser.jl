const NMEA_TYPES = [
    (r"GGA$", GGA),
    (r"GSA$", GSA),
    (r"DTM$", DTM),
    (r"GBS$", GBS),
    (r"GLL$", GLL),
    (r"GSV$", GSV),
    (r"GST$", GST),
    (r"RMC$", RMC),
    (r"VTG$", VTG),
    (r"ZDA$", ZDA),
]


"""
    nmea_parse(nmea_string::AbstractString; validate_checksum=true)

Parse an NMEA string and generate the corresponding NMEA type.

This function takes an NMEA sentence as input, validates the checksum if `validate_checksum` is
set to `true`, and then parses the sentence based on the predefined headers and types in `NMEA_TYPES`.

# Arguments
- `nmea_string::AbstractString`: The NMEA sentence to parse.
- `validate_checksum::Bool`: Flag to indicate whether to validate the checksum (default is `true`).

# Returns
- An instance of the appropriate NMEA type.

# Examples
```julia
result = nmea_parse("\$GGA,123456,123.456,N,987.654,W,1,8,0.9,123.4,M,54.3,M,1,")
```

"""
function nmea_parse(nmea_string::T; validate_checksum = true) where { T <: AbstractString }
    isempty(nmea_string) && throw(BoundsError("Input string is empty"))

    message, checksum =
        contains(nmea_string, "*") ? split(nmea_string, '*') : (nmea_string, 00)

    valid = validate_checksum ? Base.parse(UInt8, "0x$checksum") === hash_msg(message) : true

    items = split(message, ',', keepempty=true)
    header = items |> first
    system = header |> get_system

    @do_parse NMEA_TYPES header items system valid

    throw(ArgumentError("NMEA string ($header) not supported"))
end

parse(nmea_string::AbstractString; validate_checksum = true) = nmea_parse(nmea_string, validate_checksum=validate_checksum)

"""
	NMEAData()

A mutable struct that stores the last parsed NMEA messages of different types.

# Fields
- `last_GGA::Union{Nothing, GGA}`: the last GGA message parsed, or nothing if none
- `last_RMC::Union{Nothing, RMC}`: the last RMC message parsed, or nothing if none
- `last_GSA::Union{Nothing, GSA}`: the last GSA message parsed, or nothing if none
- `last_GSV::Union{Nothing, GSV}`: the last GSV message parsed, or nothing if none
- `last_GST::Union{Nothing, GST}`: the last GST message parsed, or nothing if none
- `last_GBS::Union{Nothing, GBS}`: the last GBS message parsed, or nothing if none
- `last_VTG::Union{Nothing, VTG}`: the last VTG message parsed, or nothing if none
- `last_GLL::Union{Nothing, GLL}`: the last GLL message parsed, or nothing if none
- `last_ZDA::Union{Nothing, ZDA}`: the last ZDA message parsed, or nothing if none
- `last_DTM::Union{Nothing, DTM}`: the last DTM message parsed, or nothing if none
"""
mutable struct NMEAData
    last_GGA::Union{Nothing,GGA}
    last_RMC::Union{Nothing,RMC}
    last_GSA::Union{Nothing,GSA}
    last_GSV::Union{Nothing,GSV}
    last_GST::Union{Nothing,GST}
    last_GBS::Union{Nothing,GBS}
    last_VTG::Union{Nothing,VTG}
    last_GLL::Union{Nothing,GLL}
    last_ZDA::Union{Nothing,ZDA}
    last_DTM::Union{Nothing,DTM}

    function NMEAData()
        new(nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing)
    end # constructor NMEAData
end # type NMEAData

"""
	update!(s::NMEAData, msg)

Update the corresponding field of `s` with the given NMEA message `msg`.

# Arguments
- `s::NMEAData`: the NMEA data struct to be updated
- `msg`: an NMEA message of type GGA, RMC, GSA, GSV, GBS, VTG, GLL, ZDA, DTM

"""
update!(s::NMEAData, msg::GGA) = s.last_GGA = msg
update!(s::NMEAData, msg::RMC) = s.last_RMC = msg
update!(s::NMEAData, msg::GSA) = s.last_GSA = msg
update!(s::NMEAData, msg::GSV) = s.last_GSV = msg
update!(s::NMEAData, msg::GST) = s.last_GST = msg
update!(s::NMEAData, msg::GBS) = s.last_GBS = msg
update!(s::NMEAData, msg::VTG) = s.last_VTG = msg
update!(s::NMEAData, msg::GLL) = s.last_GLL = msg
update!(s::NMEAData, msg::ZDA) = s.last_ZDA = msg
update!(s::NMEAData, msg::DTM) = s.last_DTM = msg

"""
	update(msg::T, s::NMEAData) where T <: NMEAString

Update the last received message of type T in the NMEAData object s with the given message msg.
Return the updated NMEAData object s.
"""
update(msg::GGA, s::NMEAData) = (s.last_GGA = msg; s)
update(msg::RMC, s::NMEAData) = (s.last_RMC = msg; s)
update(msg::GSA, s::NMEAData) = (s.last_GSA = msg; s)
update(msg::GSV, s::NMEAData) = (s.last_GSV = msg; s)
update(msg::GST, s::NMEAData) = (s.last_GST = msg; s)
update(msg::GBS, s::NMEAData) = (s.last_GBS = msg; s)
update(msg::VTG, s::NMEAData) = (s.last_VTG = msg; s)
update(msg::GLL, s::NMEAData) = (s.last_GLL = msg; s)
update(msg::ZDA, s::NMEAData) = (s.last_ZDA = msg; s)
update(msg::DTM, s::NMEAData) = (s.last_DTM = msg; s)

"""
	pop!(nmea_data::NMEAData, ::Type{T}) where T <: NMEAString

Pop the last received message of type T from the NMEAData object nmea_data and return it.
If no message of type T has been received, throw an MissingException.
This function extends the Base.pop! function for NMEAData objects.
"""
function pop!(nmea_data::NMEAData, ::Type{GGA})::GGA
    last =
        (isnothing(nmea_data.last_GGA) ? throw(MissingException("last_GGA not defined")) :
        nmea_data.last_GGA)::GGA
    nmea_data.last_GGA = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{RMC})
    last =
        isnothing(nmea_data.last_RMC) ? throw(MissingException("last_RMC not defined")) :
        nmea_data.last_RMC
    nmea_data.last_RMC = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GSA})
    last =
        isnothing(nmea_data.last_GSA) ? throw(MissingException("last_GSA not defined")) :
        nmea_data.last_GSA
    nmea_data.last_GSA = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GSV})
    last =
        isnothing(nmea_data.last_GSV) ? throw(MissingException("last_GSV not defined")) :
        nmea_data.last_GSV
    nmea_data.last_GSV = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GST})
    last =
        isnothing(nmea_data.last_GST) ? throw(MissingException("last_GST not defined")) :
        nmea_data.last_GST
    nmea_data.last_GST = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GBS})
    last =
        isnothing(nmea_data.last_GBS) ? throw(MissingException("last_GBS not defined")) :
        nmea_data.last_GBS
    nmea_data.last_GBS = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{VTG})
    last =
        isnothing(nmea_data.last_VTG) ? throw(MissingException("last_VTG not defined")) :
        nmea_data.last_VTG
    nmea_data.last_VTG = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GLL})
    last =
        isnothing(nmea_data.last_GLL) ? throw(MissingException("last_GLL not defined")) :
        nmea_data.last_GLL
    nmea_data.last_GLL = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{ZDA})
    last =
        isnothing(nmea_data.last_ZDA) ? throw(MissingException("last_ZDA not defined")) :
        nmea_data.last_ZDA
    nmea_data.last_ZDA = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{DTM})
    last =
        isnothing(nmea_data.last_DTM) ? throw(MissingException("last_DTM not defined")) :
        nmea_data.last_DTM
    nmea_data.last_DTM = nothing
    return last
end

"""
	parse_msg!(s::NMEAData, line::AbstractString)

Parse a line of NMEA 0183 data and update the state of an NMEAData object.

# Arguments
s : NMEAData
	An object that stores the parsed data from NMEA messages.
line : AbstractString
	A string that contains a valid NMEA 0183 message.

# Returns
DataType
	The type of the parsed message, or Nothing if the message is not supported.

# Errors
ArgumentError
	If the line is not a valid NMEA 0183 message.

# Example
```
s = NMEAData()

julia> d = [ "\$GPRMC,154925.820,A,5209.732,N,00600.240,E,001.9,059.8,040123,000.0,W*7E",
			"\$GPGGA,154925.920,5209.732,N,00600.240,E,1,12,1.0,0.0,M,0.0,M,,*63",
			"\$GPGSA,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,1.0,1.0*30",
			"\$GPRMC,154925.920,A,5209.732,N,00600.240,E,001.9,059.8,040123,000.0,W*7F"]
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
        message = nmea_parse(line)

        update!(s, message)

        return message |> typeof
    catch err
        if isa(err, ArgumentError)
            mtype = split(line, ',')[1]
            @warn "$mtype is not a supported NMEA string. skipping."
            return Nothing
        end
        rethrow()
    end
end # function parse_msg!
