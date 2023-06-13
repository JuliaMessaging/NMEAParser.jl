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

_char_xor(a::Char,b::Char) = xor(UInt8(a), UInt8(b))
_char_xor(a::UInt8,b::Char) = xor(a, UInt8(b))
_char_xor(a::Char,b::UInt8) = xor(UInt8(a), b)
hash_msg(message::AbstractString)::UInt8 = foldl(_char_xor, chopprefix(message, "\$"))

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
    elseif (occursin(r"^\$P[A,T]", mtype))
        system = "PROPRIETARY"

    # TODO: support more system types message
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
        occursin(r"GST$", header) ||
        occursin(r"GSV$", header) ||
        occursin(r"RMC$", header) ||
        occursin(r"VTG$", header) ||
        occursin(r"ZDA$", header)
    )
        return true
    else
        return false
    end
end

"""
    _to_int(item)
Converts a string representing an integer to a Int, if parse fails it defaults to 0.
"""
_to_int(item::AbstractString)::Int = something(tryparse(Int, item), 0)
_to_int(::Nothing)::Int = 0
_to_int(items::Vector{S}, idx::Int) where S <: AbstractString = _to_int(get(items, idx, nothing))

"""
_to_float(item)
Converts a string representing an float to a Float64, if parse fails it defaults to 0.0.
"""
_to_float(item::AbstractString)::Float64 = something(tryparse(Float64, item), 0.0)
_to_float(::Nothing)::Float64 = 0.0
_to_float(items::Vector{S}, idx::Int) where S <: AbstractString = _to_float(get(items, idx, nothing))

"""
    _dms_to_dd(dms, hemi)

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
function _dms_to_dd(dms::T, hemi::T)::Union{Float64, Nothing} where {T <: AbstractString}
    if dms == "" || hemi == ""
        throw(ArgumentError("Empty string cannot be parsed"))
    end

    if (dms[1:1] == "0")
        dms = dms[2:end]
    end

    decimalindex = findfirst('.', dms)
    if isnothing(decimalindex)
        throw(ArgumentError("Missing decimal index"))
    end
    degrees = Base.parse(Float64, dms[1:decimalindex-3])
    minutes = Base.parse(Float64, dms[decimalindex-2:end])
    dec_degrees = degrees + (minutes / 60)

    if (hemi == "S" || hemi == "W")
        dec_degrees *= -1
    end

    dec_degrees
end # function _dms_to_dd
_dms_to_dd(::Nothing, ::Nothing) = 0.0
_dms_to_dd(::Any, ::Nothing) = 0.0
_dms_to_dd(::Nothing, ::Any) = 0.0
_dms_to_dd(items::Vector{S}, idx::Int) where S <: AbstractString = _dms_to_dd(get(items, idx, nothing), get(items, idx+1, nothing))

"""
    _hms_to_secs(hms)

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
function _hms_to_secs(hms::T)::Float64 where { T <: AbstractString }
    if length(hms) < 6
        throw(ArgumentError("Not enough characters to be a time value"))
    end
    hours = Base.parse(Float64, hms[1:2])
    minutes = Base.parse(Float64, hms[3:4])
    seconds = Base.parse(Float64, hms[5:end])
    (hours * 3600) + (minutes * 60) + seconds
end # function _hms_to_secs
_hms_to_secs(::Nothing) = 0.0
_hms_to_secs(items::Vector{S}, idx::Int) where S <: AbstractString = _hms_to_secs(get(items, idx, nothing))
