import Base: parse

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

    checksum = Char(Base.parse(Int64, "0x$checksum"))
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

    throw(ArgumentError("NMEA string not supported"))

end
