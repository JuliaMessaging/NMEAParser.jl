"""
    parse(nmea_string::AbstractString)

A function that parses a NMEA string, which is a standard format for data
transmission from marine and navigation devices.

# Arguments
- `nmea_string::AbstractString`: The NMEA string to be parsed.

# Returns
A struct that represents the type and content of the NMEA string, such as DTM,
GBS, GGA, GLL, GSA, GSV, RMC, VTG, ZDA, PASHR, or TWPOS. The struct has fields
that correspond to the items in the NMEA string.

# Errors
Throws an `ArgumentError` if the NMEA string is not supported or has an invalid format.

# Algorithm
The function splits the NMEA string by the '*' character and checks the checksum
of the message. It then splits the message by the ',' character and extracts the
header and the items. It determines the system name from the header and calls the
appropriate constructor for the corresponding struct type. If no matching struct type
is found, it throws an `ArgumentError`.
"""
function parse(nmea_string::AbstractString)
    message, checksum  = contains(nmea_string, "*") ? split(nmea_string, '*') : (nmea_string, 00)

    checksum = Base.parse(Int64, "0x$checksum") |> Char
    hash = Char(xor(Vector{UInt8}(split(message, "\$")[2])...))

    valid = checksum === hash
    if !valid
        @warn "Message checksum mismatch"
        # println("MESSAGE: ", message)
        # println("CHECKSUM: ", checksum, " | ", Char(checksum))
        # println("HASH: ", hash)
    end

    items = split(message, ',')

    header = items |> first
    system = header |> get_system

    if (occursin(r"DTM$", header))
        return DTM(items, system=system, valid=valid)
    elseif (occursin(r"GBS$", header))
        return GBS(items, system=system, valid=valid)
    elseif (occursin(r"GGA$", header))
        return GGA(items, system=system, valid=valid)
    elseif (occursin(r"GLL$", header))
        return GLL(items, system=system, valid=valid)
    elseif (occursin(r"GSA$", header))
        return GSA(items, system=system, valid=valid)
    elseif (occursin(r"GSV$", header))
        return GSV(items, system=system, valid=valid)
    elseif (occursin(r"RMC$", header))
        return RMC(items, system=system, valid=valid)
    elseif (occursin(r"VTG$", header))
        return VTG(items, system=system, valid=valid)
    elseif (occursin(r"ZDA$", header))
        return ZDA(items, system=system, valid=valid)
    elseif (occursin(r"PASHR$", header))
        return PASHR(items, system=system, valid=valid)
    elseif (occursin(r"TWPOS$", header))
        return TWPOS(items, system=system, valid=valid)
    end

    throw(ArgumentError("NMEA string ($header) not supported"))

end

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
    update(msg::T, s::NMEAData) where T <: NMEAString

Update the last received message of type T in the NMEAData object s with the given message msg.
Return the updated NMEAData object s.
"""
update(msg::GGA, s::NMEAData) = (s.last_GGA = msg; s)
update(msg::RMC, s::NMEAData) = (s.last_RMC = msg; s)
update(msg::GSA, s::NMEAData) = (s.last_GSA = msg; s)
update(msg::GSV, s::NMEAData) = (s.last_GSV = msg; s)
update(msg::GBS, s::NMEAData) = (s.last_GBS = msg; s)
update(msg::VTG, s::NMEAData) = (s.last_VTG = msg; s)
update(msg::GLL, s::NMEAData) = (s.last_GLL = msg; s)
update(msg::ZDA, s::NMEAData) = (s.last_ZDA = msg; s)
update(msg::DTM, s::NMEAData) = (s.last_DTM = msg; s)
update(msg::PASHR, s::NMEAData) = (s.last_PASHR = msg; s)
update(msg::TWPOS, s::NMEAData) = (s.last_TWPOS = msg; s)

"""
    pop!(nmea_data::NMEAData, ::Type{T}) where T <: NMEAString

Pop the last received message of type T from the NMEAData object nmea_data and return it.
If no message of type T has been received, throw an UndefVarError.
This function extends the Base.pop! function for NMEAData objects.
"""
function pop!(nmea_data::NMEAData, ::Type{GGA})
    last = isnothing(nmea_data.last_GGA) ? throw(UndefVarError("last_GGA not defined")) : nmea_data.last_GGA
    nmea_data.last_GGA = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{RMC})
    last = isnothing(nmea_data.last_RMC) ? throw(UndefVarError("last_RMC not defined")) : nmea_data.last_RMC
    nmea_data.last_RMC = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GSA})
    last = isnothing(nmea_data.last_GSA) ? throw(UndefVarError("last_GSA not defined")) : nmea_data.last_GSA
    nmea_data.last_GSA = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GSV})
    last = isnothing(nmea_data.last_GSV) ? throw(UndefVarError("last_GSV not defined")) : nmea_data.last_GSV
    nmea_data.last_GSV = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GBS})
    last = isnothing(nmea_data.last_GBS) ? throw(UndefVarError("last_GBS not defined")) : nmea_data.last_GBS
    nmea_data.last_GBS = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{VTG})
    last = isnothing(nmea_data.last_VTG) ? throw(UndefVarError("last_VTG not defined")) : nmea_data.last_VTG
    nmea_data.last_VTG = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{GLL})
    last = isnothing(nmea_data.last_GLL) ? throw(UndefVarError("last_GLL not defined")) : nmea_data.last_GLL
    nmea_data.last_GLL = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{ZDA})
    last = isnothing(nmea_data.last_ZDA) ? throw(UndefVarError("last_ZDA not defined")) : nmea_data.last_ZDA
    nmea_data.last_ZDA = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{DTM})
    last = isnothing(nmea_data.last_DTM) ? throw(UndefVarError("last_DTM not defined")) : nmea_data.last_DTM
    nmea_data.last_DTM = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{PASHR})
    last = isnothing(nmea_data.last_PASHR) ? throw(UndefVarError("last_PASHR not defined")) : nmea_data.last_PASHR
    nmea_data.last_PASHR = nothing
    return last
end
function pop!(nmea_data::NMEAData, ::Type{TWPOS})
    last = isnothing(nmea_data.last_TWPOS) ? throw(UndefVarError("last_TWPOS not defined")) : nmea_data.last_TWPOS
    nmea_data.last_TWPOS = nothing
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
