"""
    @do_parse(headers, header_str, items, system, valid)

Macro for parsing NMEA sentences based on predefined headers.

This macro generates code to match the given `header_str` against a list of regular expressions
provided in the `headers` tuple. For each matching header, it generates code to call the corresponding
type constructor with the relevant information from the NMEA sentence.

# Arguments
- `headers::Tuple`: A tuple containing pairs of regular expressions and corresponding NMEA types.
- `header_str::AbstractString`: The NMEA sentence header string.
- `items::AbstractString`: The NMEA sentence items.
- `system::AbstractString`: The system identifier.
- `valid::Bool`: A boolean indicating whether the NMEA sentence is valid.

# Examples
```julia
@do_parse NMEA_TYPES header items system valid
```

"""
macro do_parse(headers, header_str, items, system, valid)
    code = Expr(:block)
    for (header_regex, T) in eval(headers)
        push!(
            code.args,
            quote
                if (occursin($(header_regex), $(esc(header_str))))
                    return $T(
                        $(esc(items)),
                        system = $(esc(system)),
                        valid = $(esc(valid)),
                    )
                end
            end,
        )
    end
    quote
        $(code.args...) # COV_EXCL_LINE
    end
end

function hash_msg(message::AbstractString)
    xor.(Vector{UInt8}(split(message, "\$")[2])...)
end

"""
    get_system(mtype::SubString)

Determine the system type based on the input `mtype`.

# Arguments
- `mtype`: A `SubString` representing the message type.

# Returns
- A string representing the system type. Possible values are `"GPS"`, `"GLONASS"`, `"GALILEO"`, `"COMBINED"`, and `"UNKNOWN"`.

# Examples
```julia
get_system("\$GPGGA") # "GPS"
get_system("\$GLGSV") # "GLONASS"
get_system("\$GAGGA") # "GALILEO"
get_system("\$GNGNS") # "COMBINED"
get_system("\$PMTK")  # "UNKNOWN"
```
TODO: update `get_system` to cover all common system types
\$AI = Alarm Indicator, (AIS?)
\$AP = Auto Pilot (pypilot?)
\$BD = BeiDou (China)
\$CD = Digital Selective Calling (DSC)
\$EC = Electronic Chart Display & Information System (ECDIS)
\$GA = Galileo Positioning System
\$GB = BeiDou (China)
\$GI = NavIC, IRNSS (India)
\$GL = GLONASS, according to IEIC 61162-1
\$GN = Combination of multiple satellite systems (NMEA 1083)
\$GP = Global Positioning System receiver
\$GQ = QZSS regional GPS augmentation system (Japan)
\$HC = Heading/Compass
\$HE = Gyro, north seeking
\$II = Integrated Instrumentation
\$IN = Integrated Navigation
\$LC = Loran-C receiver (obsolete)
\$Pxxx = Proprietary (Vendor specific)
\$PQ = QZSS (Quectel Quirk)
\$QZ = QZSS regional GPS augmentation system (Japan)
\$SD = Depth Sounder
\$ST = Skytraq
\$TI = Turn Indicator
\$YX = Transducer
\$WI = Weather Instrument

"""
function get_system(mtype::SubString)
    system = ""

    # GPS
    if (occursin(r"^\$GP", mtype))
        system = "GPS"

        # GLONASS
    elseif (occursin(r"^\$GL", mtype))
        system = "GLONASS"

        # GALILEO
    elseif (occursin(r"^\$GA", mtype))
        system = "GALILEO"

        # BeiDou
    elseif (occursin(r"^\$GB", mtype) || occursin(r"^\$BD", mtype))
        system = "BEIDOU"

        # Combined
    elseif (occursin(r"^\$GN", mtype))
        system = "COMBINED"

        # Proprietary (non-NMEA standard) message
    else
        system = "UNKNOWN"
    end

    system
end # function get_system

"""
    is_string_supported(nmea_string::AbstractString)

Check if the input NMEA string type is supported.

# Arguments
- `nmea_string::AbstractString`: The NMEA string to be checked.

# Returns
- `Bool`: `true` if the NMEA string is supported, `false` otherwise.

# Example
```julia
julia> is_string_supported("\$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47")
true
```
"""
function is_string_supported(nmea_string::AbstractString)
    message, checksum =
        contains(nmea_string, "*") ? split(nmea_string, '*') : (nmea_string, 00)
    header = split(message, ',') |> first

    if (
        occursin(r"DTM$", header) ||
        occursin(r"GBS$", header) ||
        occursin(r"GGA$", header) ||
        occursin(r"GLL$", header) ||
        occursin(r"GSA$", header) ||
        occursin(r"GSV$", header) ||
        occursin(r"RMC$", header) ||
        occursin(r"VTG$", header) ||
        occursin(r"ZDA$", header) ||
        occursin(r"PASHR$", header) ||
        occursin(r"TWVCT$", header) ||
        occursin(r"TWPOS$", header) ||
        occursin(r"TWPLS$", header) ||
        occursin(r"TWWHE$", header) ||
        occursin(r"TWHPR$", header)
    )
        return true
    else
        return false
    end
end

function is_string_proprietary(nmea_string::AbstractString)
    message, checksum =
        contains(nmea_string, "*") ? split(nmea_string, '*') : (nmea_string, 00)
    header = split(message, ',') |> first

    if (
        occursin(r"PASHR$", header) ||
        occursin(r"PTWPOS$", header) ||
        occursin(r"PTWVCT$", header) ||
        occursin(r"PTWPLS$", header) ||
        occursin(r"PTWWHE$", header) ||
        occursin(r"PTWHPR$", header) ||
        occursin(r"PTACC$", header) ||
        occursin(r"PTGYR$", header)
    )
        return true
    else
        return false
    end
end

"""
    _dms_to_dd(dms::SubString, hemi::SubString)

Converts a string representing degrees, minutes and seconds (DMS) to decimal degrees.

# Arguments
- `dms`: a substring representing degrees, minutes and seconds
- `hemi`: a substring representing the hemisphere

# Returns
- `dec_degrees`: the decimal degree representation of the input DMS

# Example
```julia
dms = "4807.038"
hemi = "N"
dec_degrees = _dms_to_dd(dms, hemi)
```
"""
function _dms_to_dd(dms::SubString, hemi::SubString)::Float64
    if (dms[1:1] == "0")
        dms = dms[2:end]
    end

    decimalindex = findfirst('.', dms)
    degrees = Base.parse(Float64, dms[1:decimalindex-3])
    minutes = Base.parse(Float64, dms[decimalindex-2:end])
    dec_degrees = degrees + (minutes / 60)

    if (hemi == "S" || hemi == "W")
        dec_degrees *= -1
    end

    dec_degrees
end # function _dms_to_dd

"""
    _hms_to_secs(hms::SubString)

Converts a string representing hours, minutes and seconds (HMS) to seconds.

# Arguments
- `hms`: a substring representing hours, minutes and seconds

# Returns
- `seconds`: the number of seconds represented by the input HMS

# Example
```julia
hms = "123519"
seconds = _hms_to_secs(hms)
```
"""
function _hms_to_secs(hms::SubString)::Float64
    hours = Base.parse(Float64, hms[1:2])
    minutes = Base.parse(Float64, hms[3:4])
    seconds = Base.parse(Float64, hms[5:end])
    (hours * 3600) + (minutes * 60) + seconds
end # function _hms_to_secs

"""
    pos_convert(flag::Char, value::Float64)::Float64

A function that converts a position value from one unit to another.

# Arguments
- `flag::Char`: The flag that indicates the original unit of the position value.
  Possible values are 'F' for feet, 'N' for miles, 'K' for kilometers, and 'M' for meters.
- `value::Float64`: The position value to be converted.

# Returns
A `Float64` that represents the position value in meters.

# Errors
Throws an exception if the flag is not one of the supported values.

# Algorithm
The function uses a simple formula to convert the position value based on the flag.
For example, if the flag is 'F', it divides the value by 0.3048 to get the equivalent
value in meters.
"""
function pos_convert(flag::Char, value::Float64)::Float64
    if flag == 'F'
        # F feet
        return value * 0.3048
    elseif flag == 'N'
        # N miles
        return value * 1609.344
    elseif flag == 'K'
        # K kilometer
        return value * 1000.0
    elseif flag == 'M'
        # M meter
        return value
    else
        throw(ArgumentError("Position unit $flag is not supported"))
    end
end


"""
    vel_convert(flag::Char, value::Float64)::Float64

A function that converts a velocity value from one unit to another.

# Arguments
- `flag::Char`: The flag that indicates the original unit of the velocity value.
  Possible values are 'N' for knots, 'K' for kilometers per hour, and 'M' for meters per second.
- `value::Float64`: The velocity value to be converted.

# Returns
A `Float64` that represents the velocity value in meters per second.

# Errors
Throws an exception if the flag is not one of the supported values.

# Algorithm
The function uses a simple formula to convert the velocity value based on the flag.
"""
function vel_convert(flag::Char, value::Float64)::Float64
    if flag == 'N'
        # N knots
        return value / 1.94384449244
    elseif flag == 'K'
        # K kilometer per hour
        return value / 3.6
    elseif flag == 'M'
        # M meters per second
        return value
    else
        throw(ArgumentError("Velocity unit $flag is not supported"))
    end
end

function orientation_convert(flag::Char, value::Float64)::Float64
    # TODO: implement
    # if flag == 'R'
    #     return value
    # elseif flag == 'D'
    # else
    #     throw(ArgumentError("Orientation unit $flag is not supported"))
    # end
    return value
end
