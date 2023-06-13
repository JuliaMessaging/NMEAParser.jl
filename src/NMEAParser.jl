module NMEAParser

export NMEAData, parse_msg!, GGA,
       RMC, GSA, GSV, SVData,
       GBS, VTG, GLL, ZDA,
       DTM, parse


"""
    parse(line::AbstractString)

Parses an NMEA sentence, returning a corresponding type.

# Arguments
- `line::AbstractString`
"""
function parse(line::AbstractString)

    message, checksum  = split(line, '*')

    checksum = Char(Base.parse(Int64, "0x$checksum"))
    hash = Char(xor(Vector{UInt8}(split(message, "\$")[2])...))

    if checksum !== hash
        @warn "Message checksum mismatch"
        # println("MESSAGE: ", message)
        # println("CHECKSUM: ", checksum, " | ", Char(checksum))
        # println("HASH: ", hash)
    end

    items = split(message, ',')

    system = get_system(items[1])

    if (occursin(r"DTM$", items[1]))
        return parse_DTM(items, system)
    elseif (occursin(r"GBS$", items[1]))
        return parse_GBS(items, system)
    elseif (occursin(r"GGA$", items[1]))
        return parse_GGA(items, system)
    elseif (occursin(r"GLL$", items[1]))
        return parse_GLL(items, system)
    elseif (occursin(r"GSA$", items[1]))
        return parse_GSA(items, system)
    elseif (occursin(r"GSV$", items[1]))
        return parse_GSV(items, system)
    elseif (occursin(r"RMC$", items[1]))
        return parse_RMC(items, system)
    elseif (occursin(r"VTG$", items[1]))
        return parse_VTG(items, system)
    elseif (occursin(r"ZDA$", items[1]))
        return parse_ZDA(items, system)
    elseif (occursin(r"PASHR$", items[1]))
        return parse_PASHR(items, system)
    elseif (occursin(r"TWPOS$", items[1]))
        return parse_TWPOS(items, system)
    end

    throw(ArgumentError("NMEA string not supported"))

end

"""
    GGA(sys::AbstractString)

A mutable struct representing a GGA (Global Positioning System Fix Data) message.

# Fields
- `system`: GPS, GLONASS, GALILEO, or Combined.
- `time`: Time in seconds.
- `latitude`: Latitude in decimal degrees.
- `longitude`: Longitude in decimal degrees.
- `fix_quality`: Quality of the fix.
- `num_sats`: Number of satellites used in the fix.
- `HDOP`: Horizontal Dilution of Precision.
- `altitude`: Altitude above Mean Sea Level in meters.
- `geoidal_seperation`: Geoidal separation in meters.
- `age_of_differential`: Age of differential data in seconds since last SC104 type 1 or 9 update.
- `diff_reference_id`: Differential reference station ID.
- `valid`: Whether the data is valid.

# Constructor
The constructor takes one argument:
- `sys::AbstractString`: The system type (GPS, GLONASS, GALILEO, or Combined).

# Examples
```julia
gga = GGA("GPS")
```
"""
mutable struct GGA
    system # GPS, GLONASS, GALILEO, or Combined
    time # in seconds
    latitude # decimal degrees
    longitude # decimal degrees
    fix_quality
    num_sats
    HDOP
    altitude # MSL in meters
    geoidal_seperation # meters
    age_of_differential # seconds since last SC104
    diff_reference_id # differential reference station id
    valid

    function GGA(sys::AbstractString)
        system              = sys
        time                = 0.0
        latitude            = 0.0
        longitude           = 0.0
        fix_quality         = "UNKNOWN"
        num_sats            = 0
        HDOP                = 0.0
        altitude            = 0.0
        geoidal_seperation  = 0.0
        age_of_differential = 0.0
        diff_reference_id   = 0
        valid               = false
        new(system, time, latitude,
            longitude, fix_quality, num_sats,
            HDOP, altitude, geoidal_seperation,
            age_of_differential, diff_reference_id,
            valid)
    end # constructor GGA

end # type GGA

#----------
# GSA message type - GNSS DOP and Active Satellites
#----------
mutable struct GSA
    system
    mode
    current_mode
    sat_ids
    PDOP
    HDOP
    VDOP
    valid

    function GSA(sys::AbstractString)
        system       = sys
        mode         = 'M'
        current_mode = 0
        sat_ids      = []
        PDOP         = 0.0
        HDOP         = 0.0
        VDOP         = 0.0
        valid        = false
        new(system, mode, current_mode,
            sat_ids, PDOP, HDOP,
            VDOP, valid)
    end # constructor GSA
end # type GSA

#----------
# ZDA message type - Time and Date
#----------
mutable struct ZDA
    system
    time
    day
    month
    year
    zone_hrs
    zone_mins
    valid

    function ZDA(sys::AbstractString)
        system    = sys
        time      = 0.0
        day       = 0
        month     = 0
        year      = 0
        zone_hrs  = 0
        zone_mins = 0
        valid     = false
        new(system, time, day,
            month, year, zone_hrs,
            zone_mins, valid)
    end # constructor ZDA

end # type ZDA

#----------
# GBS message type - RAIM GNSS Satellite Fault Detection
#----------
mutable struct GBS
    system
    time
    lat_error
    long_error
    alt_error
    failed_PRN
    prob_of_missed
    excluded_meas_err
    standard_deviation
    valid

    function GBS(sys::AbstractString)
        system             = sys
        time               = 0.0
        lat_error          = 0.0
        long_error         = 0.0
        alt_error          = 0.0
        failed_PRN         = 0
        prob_of_missed     = 0.0
        excluded_meas_err  = 0.0
        standard_deviation = 0.0
        valid              = false
        new(system, time, lat_error,
            long_error, alt_error, failed_PRN,
            prob_of_missed, excluded_meas_err, standard_deviation,
            valid)
    end # constructor GBS
end # type GBS

#----------
# GLL message type - Geographic Position –
# Latitude/Longitude
#----------
mutable struct GLL
    system
    latitude
    longitude
    time
    status
    mode
    valid

    function GLL(sys::AbstractString)
        system    = sys
        latitude  = 0.0
        longitude = 0.0
        time      = 0.0
        status    = false
        mode      = 'N'
        valid     = false
        new(system, latitude, longitude,
            time, status, mode,
            valid)
    end # constructor GLL
end # type GLL

#----------
# type to store SV data fields in GSV
#----------
mutable struct SVData
    PRN
    elevation
    azimuth
    SNR

    function SVData()
        PRN       = 0
        elevation = 0
        azimuth   = 0
        SNR       = 0
        new(PRN, elevation, azimuth,
            SNR)
    end # constructor SVData
end # type SVData

#-----------
# type for GSV messages - GNSS Satellites In View
#-----------
mutable struct GSV
    system
    msg_total
    msg_num
    sat_total
    SV_data
    valid

    function GSV(sys::AbstractString)
        system    = sys
        msg_total = 0
        msg_num   = 0
        sat_total = 0
        SV_data   = []
        valid     = false
        new(system, msg_total, msg_num,
            sat_total, SV_data, valid)
    end # constructor GSV
end # type GSV

#----------
# RMC message type - Recommended Minimum Specific GNSS Data
#----------
mutable struct RMC
    system
    time
    status
    latitude
    longitude
    sog
    cog
    day
    month
    year
    magvar
    mode
    valid

    function RMC(sys::AbstractString)
        system    = sys
        time      = 0.0
        status    = false
        latitude  = 0.0
        longitude = 0.0
        sog       = 0.0
        cog       = 0.0
        day       = "00"
        month     = "00"
        year      = "00"
        magvar    = 0.0
        mode      = 'N'
        valid     = false
        new(system, time, status,
            latitude, longitude, sog,
            cog, day, month, year, magvar,
            mode, valid)
    end # constructor RMC
end # type RMC

#----------
# VTG message type - Course over Ground & Ground Speed
#----------
mutable struct VTG
    CoG_true
    CoG_mag
    SoG_knots
    SoG_kmhr
    mode
    valid

    function VTG(sys::AbstractString)
        CoG_true  = 0.0
        CoG_mag   = 0.0
        SoG_knots = 0.0
        SoG_kmhr  = 0.0
        mode      = 'N'
        valid     = false
        new(CoG_true, CoG_mag, SoG_knots,
            SoG_kmhr, mode, valid)
    end # constructor VTG

end # type VTG

#----------
# DTM message type - Datum
#----------
mutable struct DTM
    system
    local_datum_code
    local_datum_subcode
    lat_offset
    long_offset
    alt_offset
    ref_datum
    valid

    function DTM(sys::AbstractString)
        system              = sys
        local_datum_code    = ""
        local_datum_subcode = ""
        lat_offset          = 0.0
        long_offset         = 0.0
        alt_offset          = 0.0
        ref_datum           = ""
        valid               = false

        new(system, local_datum_code, local_datum_subcode,
            lat_offset, long_offset, alt_offset,
            ref_datum, valid)
    end # constructor DTM
end # type DTM


mutable struct PASHR
    system
    time
    heading
    heading_type
    roll
    pitch
    heave
    roll_accuracy
    pitch_accuracy
    heading_accuracy
    aiding_code
    ins_code
    valid

    function PASHR(sys::AbstractString)
        system  = sys
        time = 0.0
        heading = 0.0
        heading_type = "T"
        roll = 0.0
        pitch = 0.0
        heave = 0.0
        roll_accuracy = 0.0
        pitch_accuracy = 0.0
        heading_accuracy = 0.0
        aiding_code = 0
        ins_code = 0
        valid    = false
        new(system, heading, heading_type, roll, pitch, heave, roll_accuracy,
         pitch_accuracy, heading_accuracy, aiding_code, ins_code, valid)
    end

end # type PASHR

"""
    mutable struct TWPOS

A mutable structure representing a TWPOS sentence from a GPS system.

# Fields
- `system`: the GPS system
- `time`: the time of the sentence
- `xpose`: the x position
- `ypose`: the y position
- `zpose`: the z position
- `distance`: the distance
- `velocity`: the velocity
- `valid`: a boolean indicating if the sentence is valid

# Constructor
```julia
TWPOS(sys::AbstractString)
```
Constructs a new instance of the TWPOS type with the given GPS system.

# Example
```
sys = "GPS"
TWPOS_data = TWPOS(sys)
```
"""
mutable struct TWPOS
    system::Any
    time::Any
    xpose::Float64
    ypose::Float64
    zpose::Float64
    distance::Float64
    velocity::Float64
    valid::Bool

    function TWPOS(sys::AbstractString)
        system = sys
        time = 0.0
        xpose = 0.0
        ypose = 0.0
        zpose = 0.0
        distance = 0.0
        velocity = 0.0
        valid = false
        new(system, time, xpose, ypose, zpose, distance, velocity, valid)
    end # constructor TWPOS
end # type TWPOS

"""
    NMEAData()

A mutable struct representing NMEA data.

# Fields
- `last_GGA::GGA`: The last GGA message received.
- `last_RMC::RMC`: The last RMC message received.
- `last_GSA::GSA`: The last GSA message received.
- `last_GSV::GSV`: The last GSV message received.
- `last_GBS::GBS`: The last GBS message received.
- `last_VTG::VTG`: The last VTG message received.
- `last_GLL::GLL`: The last GLL message received.
- `last_ZDA::ZDA`: The last ZDA message received.
- `last_DTM::DTM`: The last DTM message received.
- `last_PASHR::PASHR`: The last PASHR message received.
- `last_TWPOS::TWPOS`: The last TWPOS message received.

# Constructor
The constructor takes no arguments and initializes all fields to their respective types with the system set to "UNKNOWN".

# Examples
```julia
nmea_data = NMEAData()
```
"""
mutable struct NMEAData
    last_GGA::GGA
    last_RMC::RMC
    last_GSA::GSA
    last_GSV::GSV
    last_GBS::GBS
    last_VTG::VTG
    last_GLL::GLL
    last_ZDA::ZDA
    last_DTM::DTM
    last_PASHR::PASHR
    last_TWPOS::TWPOS

    function NMEAData()
        last_GGA = GGA("UNKNOWN")
        last_RMC = RMC("UNKNOWN")
        last_GSA = GSA("UNKNOWN")
        last_GSV = GSV("UNKNOWN")
        last_GBS = GBS("UNKNOWN")
        last_VTG = VTG("UNKNOWN")
        last_GLL = GLL("UNKNOWN")
        last_ZDA = ZDA("UNKNOWN")
        last_DTM = DTM("UNKNOWN")
        last_PASHR = PASHR("UNKNOWN")
        last_TWPOS = TWPOS("UNKNOWN")
        new(last_GGA, last_RMC, last_GSA,
            last_GSV, last_GBS, last_VTG,
            last_GLL, last_ZDA, last_DTM, last_PASHR, last_TWPOS)
    end # constructor NMEAData
end # type NMEAData

"""
    parse_msg!(s::NMEAData, line::AbstractString)

Parses an NMEA sentence and updates the corresponding field in the `NMEAData` struct.

# Arguments
- `s::NMEAData`: The `NMEAData` struct to update.
- `line::AbstractString`: The NMEA sentence to parse.

# Returns
- Returns the type of message parsed as a string.

# Examples
```julia
nmea_data = NMEAData()
parse_msg!(nmea_data, "\$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47")
```
# Notes
The function supports parsing of DTM, GBS, GGA, GLL, GNS, GSA, GSV, RMC, VTG, ZDA, PASHR and TWPOS messages.
"""
function parse_msg!(s::NMEAData, line::AbstractString)
    message = split(line, '*')[1]
    items = split(message, ',')

    # get system name
    system = get_system(items[1])

    mtype = ""
    if (occursin(r"DTM$", items[1]))
        s.last_DTM = parse_DTM(items, system)
        mtype = "DTM"

    elseif (occursin(r"GBS$", items[1]))
        s.last_GBS = parse_GBS(items, system)
        mtype = "GBS"

    elseif (occursin(r"GGA$", items[1]))
        s.last_GGA = parse_GGA(items, system)
        mtype = "GGA"

    elseif (occursin(r"GLL$", items[1]))
        s.last_GLL = parse_GLL(items, system)
        mtype = "GLL"

    elseif (occursin(r"GNS$", items[1]))
        mtype = "GNS"

    elseif (occursin(r"GSA$", items[1]))
        s.last_GSA = parse_GSA(items, system)
        mtype = "GSA"

    elseif (occursin(r"GSV$", items[1]))
        s.last_GSV = parse_GSV(items, system)
        mtype = "GSV"

    elseif (occursin(r"RMC$", items[1]))
        s.last_RMC = parse_RMC(items, system)
        mtype = "RMC"

    elseif (occursin(r"VTG$", items[1]))
        s.last_VTG = parse_VTG(items, system)
        mtype = "VTG"

    elseif (occursin(r"ZDA$", items[1]))
        s.last_ZDA = parse_ZDA(items, system)
        mtype = "ZDA"

    elseif (occursin(r"PASHR$", items[1]))
        s.last_PASHR = parse_PASHR(items, system)
        mtype = "PASHR"
    elseif (occursin(r"TWPOS$", items[1]))
        s.last_TWPOS = parse_TWPOS(items, system)
        mtype = "TWPOS"
    else
        mtype = "PROPRIETARY"
    end
    mtype
end # function parse_msg!

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
    parse_GGA(items::Array{T}, system::AbstractString) where T <: SubString

Parse an array of substrings `items` representing a GGA sentence from a GPS system.

# Arguments
- `items`: an array of substrings representing the fields of a GGA sentence
- `system`: a string representing the GPS system

# Returns
- `GGA_data`: an instance of the `GGA` type containing the parsed data

# Example
```julia
items = ["\$GPGGA", "123519", "4807.038", "N", "01131.000", "E", "1", "08", "0.9", "545.4", "M", "46.9", "M", "", ""]
system = "GPS"
GGA_data = parse_GGA(items, system)
```
"""
function parse_GGA(items::Array{T}, system::AbstractString) where T <: SubString
    GGA_data = GGA(system)
    GGA_data.time = _hms_to_secs(items[2])
    GGA_data.latitude = _dms_to_dd(items[3], items[4])
    GGA_data.longitude = _dms_to_dd(items[5], items[6])

    fix_flag = tryparse(Int, items[7])
    if (fix_flag == 0)
        GGA_data.fix_quality = "INVALID"
    elseif (fix_flag == 1)
        GGA_data.fix_quality = "GPS (SPS)"
    elseif (fix_flag == 2)
        GGA_data.fix_quality = "DGPS"
    elseif (fix_flag == 3)
        GGA_data.fix_quality = "PPS"
    elseif (fix_flag == 4)
        GGA_data.fix_quality = "REAL TIME KINEMATIC"
    elseif (fix_flag == 5)
        GGA_data.fix_quality = "FLOAT RTK"
    elseif (fix_flag == 6)
        GGA_data.fix_quality = "DEAD RECKONING"
    elseif (fix_flag == 7)
        GGA_data.fix_quality = "MANUAL INPUT"
    elseif (fix_flag == 8)
        GGA_data.fix_quality = "SIMULATION"
    else
        GGA_data.fix_quality = "UNKNOWN"
    end

    GGA_data.num_sats            = tryparse(Int, items[8])
    GGA_data.HDOP                = tryparse(Float64, items[9])
    GGA_data.altitude            = tryparse(Float64, items[10])
    GGA_data.geoidal_seperation  = tryparse(Float64, items[12])
    GGA_data.age_of_differential = tryparse(Float64, items[14])
    GGA_data.diff_reference_id   = tryparse(Int, items[15])
    GGA_data.valid               = true
    GGA_data
end # function parse_GGA

#----------
# parse GSA messages
#----------
function parse_GSA(items::Array{T}, system::AbstractString)  where T <: SubString
    GSA_data = GSA(system)
    GSA_data.mode = items[2][1]
    GSA_data.current_mode = tryparse(Int, items[3])

    for i = 4:length(items) - 3
        if (items[i] == "")
            break
        end
        push!(GSA_data.sat_ids, tryparse(Int, items[i]))
    end

    GSA_data.PDOP  = tryparse(Float64, items[end - 2])
    GSA_data.HDOP  = tryparse(Float64, items[end - 1])
    GSA_data.VDOP  = tryparse(Float64, items[end])
    GSA_data.valid = true
    GSA_data
end # function parse_GSA

#----------
# parse ZDA message
#----------
function parse_ZDA(items::Array{T}, system::AbstractString) where T <: SubString
    ZDA_data = ZDA(system)
    ZDA_data.time      = _hms_to_secs(items[2])
    ZDA_data.day       = tryparse(Int, items[3])
    ZDA_data.month     = tryparse(Int, items[4])
    ZDA_data.year      = tryparse(Int, items[5])
    ZDA_data.zone_hrs  = tryparse(Int, items[6])
    ZDA_data.zone_mins = tryparse(Int, items[7])
    ZDA_data.valid     = true
    ZDA_data
end # function parse_ZDA

#----------
# parse GBS messages
#----------
function parse_GBS(items::Array{T}, system::AbstractString) where T <: SubString
    GBS_data                    = GBS(system)
    GBS_data.time               = _hms_to_secs(items[2])
    GBS_data.lat_error          = tryparse(Float64, items[3])
    GBS_data.long_error         = tryparse(Float64, items[4])
    GBS_data.alt_error          = tryparse(Float64, items[5])
    GBS_data.failed_PRN         = tryparse(Int, items[6])
    GBS_data.prob_of_missed     = tryparse(Float64, items[7])
    GBS_data.excluded_meas_err  = tryparse(Float64, items[8])
    GBS_data.standard_deviation = tryparse(Float64, items[9])
    GBS_data.valid              = true
    GBS_data
end # function parse_GBS

#----------
# parse GLL message
#----------
function parse_GLL(items::Array{T}, system::AbstractString) where T <: SubString
    GLL_data           = GLL(system)
    GLL_data.latitude  = _dms_to_dd(items[2], items[3])
    GLL_data.longitude = _dms_to_dd(items[4], items[5])
    GLL_data.time      = _hms_to_secs(items[6])

    if (items[7] == "A")
        GLL_data.status = true
    else
        GLL_data.status = false
    end

    if (items[8] != "")
        GLL_data.mode = items[8][1]
    end

    GLL_data.valid = true
    GLL_data
end # function parse_GLL

#----------
# parse GSV messages
#----------
function parse_GSV(items::Array{T}, system::AbstractString) where T <: SubString
    GSV_data           = GSV(system)
    GSV_data.msg_total = tryparse(Int, items[2])
    GSV_data.msg_num   = tryparse(Int, items[3])
    GSV_data.sat_total = tryparse(Int, items[4])

    i = 5
    while i < length(items)
        svd           = SVData()
        svd.PRN       = tryparse(Int, items[i])
        svd.elevation = tryparse(Int, items[i + 1])
        svd.azimuth   = tryparse(Int, items[i + 2])
        svd.SNR       = tryparse(Int, items[i + 3])
        push!(GSV_data.SV_data, svd)
        i += 4
    end

    GSV_data.valid = true
    GSV_data
end # function parse_GSV

#----------
# parse RMC messages
#----------
function parse_RMC(items::Array{T}, system::AbstractString) where T <: SubString
    RMC_data = RMC(system)
    RMC_data.time = _hms_to_secs(items[2])

    if (items[3] == "A")
        RMC_data.status = true
    else
        RMC_data.status = false
    end

    RMC_data.latitude  = _dms_to_dd(items[4], items[5])
    RMC_data.longitude = _dms_to_dd(items[6], items[7])
    RMC_data.sog       = tryparse(Float64, items[8])
    RMC_data.cog       = tryparse(Float64, items[9])
    RMC_data.day       = string(items[10][1:2])
    RMC_data.month     = string(items[10][3:4])
    RMC_data.year      = string(items[10][5:6])

    if (items[12] == "W" || items[12] == "S")
        RMC_data.magvar = tryparse(Float64, items[11]) * -1
    else
        RMC_data.magvar = tryparse(Float64, items[11])
    end
    RMC_data.mode = items[3][1]
    RMC_data.valid = true
    RMC_data
end # function parse_RMC

#----------
# parses VTG messages
#----------
function parse_VTG(items::Array{T}, system::AbstractString) where T <: SubString
    VTG_data = VTG(system)
    VTG_data.CoG_true  = tryparse(Float64, items[2])
    VTG_data.CoG_mag   = tryparse(Float64, items[4])
    VTG_data.SoG_knots = tryparse(Float64, items[6])
    VTG_data.SoG_kmhr  = tryparse(Float64, items[8])
    VTG_data.mode      = items[10][1]
    VTG_data.valid     = true
    VTG_data
end # function parse_VTG

#----------
# parse DTM messages
#----------
function parse_DTM(items::Array{T}, system::AbstractString) where T <: SubString
    DTM_data = DTM(system)
    DTM_data.local_datum_code = items[2]
    DTM_data.local_datum_subcode = items[3]
    lat_offset = tryparse(Float64, items[4])
    if (items[5] == "S")
        DTM_data.lat_offset = lat_offset * -1
    else
        DTM_data.lat_offset = lat_offset
    end

    long_offset = tryparse(Float64, items[6])
    if (items[7] == "W")
        DTM_data.long_offset = long_offset * -1
    else
        DTM_data.long_offset = long_offset
    end

    DTM_data.alt_offset = tryparse(Float64, items[8])
    DTM_data.ref_datum  = items[9]
    DTM_data.valid      = true
    DTM_data
end # function parse_DTM

function parse_PASHR(items::Array{T}, system::AbstractString) where T<:SubString
    PASHR_data = PASHR(system)
    PASHR_data.time = _hms_to_secs(items[2])
    PASHR_data.heading = tryparse(Float64, items[3])
    if (items[4]=="T")
        PASHR_data.heading_type = "True"
    else
        PASHR_data.heading_type = ""
    end
    PASHR_data.roll = tryparse(Float64, items[5])
    PASHR_data.pitch = tryparse(Float64, items[6])
    PASHR_data.heave = tryparse(Float64, items[7])
    PASHR_data.roll_accuracy = tryparse(Float64, items[8])
    PASHR_data.pitch_accuracy = tryparse(Float64, items[9])
    PASHR_data.heading_accuracy = tryparse(Float64, items[10])
    PASHR_data.aiding_code = items[11]
    if length(items)>11
        # INS status may be missing from certain systems
        PASHR_data.ins_code = items[12]
    else
        PASHR_data.ins_code = 0
    end
    PASHR_data.valid = true
    PASHR_data
end

"""
    parse_TWPOS(items::Array{T}, system::AbstractString) where T<:SubString

Parse an array of substrings `items` representing a TWPOS sentence from a GPS system.

# Arguments
- `items`: an array of substrings representing the fields of a TWPOS sentence
- `system`: a string representing the GPS system

# Returns
- `TWPOS_data`: an instance of the `TWPOS` type containing the parsed data

# Example
```julia
items = ["\$GPTWPOS", "123519", "4807.038", "M", "01131.000", "M", "545.4", "M", "46.9", "M", "0.9", "K"]
system = "GPS"
TWPOS_data = parse_TWPOS(items, system)
```
"""
function parse_TWPOS(items::Array{T}, system::AbstractString) where T<:SubString
    TWPOS_data = TWPOS(system)
    TWPOS_data.time = _hms_to_secs(items[2])

    # Todo check second value for unit (M == meter, K == kilometer, F == feet, N == miles)
    # and update accordingly to meters
    # f /= 0.3048 n *= 0.621371192237 k *= 1000
    TWPOS_data.xpose = pos_convert(only(items[4]), tryparse(Float64, items[3]))
    TWPOS_data.ypose = pos_convert(only(items[6]), tryparse(Float64, items[5]))
    TWPOS_data.zpose = pos_convert(only(items[8]), tryparse(Float64, items[7]))
    TWPOS_data.distance = pos_convert(only(items[10]), tryparse(Float64, items[9]))
    TWPOS_data.velocity = vel_convert(only(items[12]), tryparse(Float64, items[11]))
    TWPOS_data.valid = true
    TWPOS_data
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
function _dms_to_dd(dms::SubString, hemi::SubString)
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
function _hms_to_secs(hms::SubString)
    hours   = Base.parse(Float64, hms[1:2])
    minutes = Base.parse(Float64, hms[3:4])
    seconds = Base.parse(Float64, hms[5:end])
    (hours * 3600) + (minutes * 60) + seconds
end # function _hms_to_secs

"""
    pos_convert(Flag, Value)

    Convert a position Value to a different measurement system based on flag.
"""
function pos_convert(flag::Char, value::Float64)
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
    vel_convert(Flag, Value)

    Convert a velocity Value to a different measurement system based on flag.
"""
function vel_convert(flag::Char, value::Float64)
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

end # module NMEAParser
