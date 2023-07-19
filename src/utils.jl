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
    hours   = Base.parse(Float64, hms[1:2])
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
        return value / 0.3048
    elseif flag == 'N'
        # N miles
        return value * 0.621371192237
    elseif flag == 'K'
        # K kilometer
        return value * 1000.
    elseif flag == 'M'
        # M meter
        return value
    else
        throw("Velocity unit $flag is not supported")
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
For example, if the flag is 'N', it multiplies the value by 1.94384449244 to get the equivalent
value in meters per second.
"""
function vel_convert(flag::Char, value::Float64)::Float64
    if flag == 'N'
        # N knots
        return value * 1.94384449244
    elseif flag == 'K'
        # K kilometer per hour
        return value * 3.6
    elseif flag == 'M'
        # M meters per second
        return value
    else
        throw("Velocity unit $flag is not supported")
    end
end
