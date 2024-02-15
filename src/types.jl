abstract type NMEAString end

"""
    struct GGA <: NMEAString

GPS Fix Data (GGA)

This NMEA data type represents information about the GPS fix, including latitude, longitude, altitude,
number of satellites, and accuracy measures.

# Fields
- `system::String`: GPS, GLONASS, GALILEO, or Combined.
- `time::Float64`: Time in seconds.
- `latitude::Float64`: Latitude in decimal degrees.
- `longitude::Float64`: Longitude in decimal degrees.
- `fix_quality::String`: Quality of the fix.
- `num_sats::Int`: Number of satellites used in the fix.
- `HDOP::Float64`: Horizontal Dilution of Precision.
- `altitude::Float64`: Altitude above mean sea level (MSL) in meters.
- `geoidal_separation::Float64`: Geoidal separation in meters.
- `age_of_differential::Float64`: Age of the differential data.
- `diff_reference_id::Int`: Differential reference station ID.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
GGA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = GGA(["GGA", "123456", "123.456", "N", "987.654", "W", "1", "8", "0.9", "123.4", "M", "54.3", "M", "1"])
```

"""
struct GGA <: NMEAString
    system::String # GPS, GLONASS, GALILEO, or Combined
    time::Float64 # in seconds
    latitude::Float64 # decimal degrees
    longitude::Float64 # decimal degrees
    fix_quality::String
    num_sats::Int
    HDOP::Float64
    altitude::Float64 # MSL in meters
    geoidal_seperation::Float64 # meters
    age_of_differential::Float64 # seconds since last SC104
    diff_reference_id::Int # differential reference station id
    valid::Bool

    function GGA(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        fix_flag = tryparse(Int, items[7])
        fix_quality = "UNKNOWN"
        if (fix_flag == 0)
            fix_quality = "INVALID"
        elseif (fix_flag == 1)
            fix_quality = "GPS (SPS)"
        elseif (fix_flag == 2)
            fix_quality = "DGPS"
        elseif (fix_flag == 3)
            fix_quality = "PPS"
        elseif (fix_flag == 4)
            fix_quality = "REAL TIME KINEMATIC"
        elseif (fix_flag == 5)
            fix_quality = "FLOAT RTK"
        elseif (fix_flag == 6)
            fix_quality = "DEAD RECKONING"
        elseif (fix_flag == 7)
            fix_quality = "MANUAL INPUT"
        elseif (fix_flag == 8)
            fix_quality = "SIMULATION"
        end
        new(
            system,
            _hms_to_secs(items[2]),
            _dms_to_dd(items[3], items[4]),
            _dms_to_dd(items[5], items[6]),
            fix_quality,
            something(tryparse(Int, items[8]), 0),
            something(tryparse(Float64, items[9]), 0.0),
            something(tryparse(Float64, items[10]), 0.0),
            something(tryparse(Float64, items[12]), 0.0),
            something(tryparse(Float64, items[14]), 0.0),
            something(tryparse(Int, items[15]), 0),
            valid,
        )
    end # constructor GGA

end # type GGA


"""
    struct GSA <: NMEAString

GNSS DOP and Active Satellites (GSA)

This NMEA data type represents information about the GNSS Dilution of Precision (DOP) and the active
satellites used for navigation.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `mode::Char`: Mode of operation (A = Automatic, M = Manual).
- `current_mode::Int`: Operating mode (1 = Fix not available, 2 = 2D fix, 3 = 3D fix).
- `sat_ids::Vector{Int}`: Vector of satellite IDs used in the fix.
- `PDOP::Float64`: Position Dilution of Precision.
- `HDOP::Float64`: Horizontal Dilution of Precision.
- `VDOP::Float64`: Vertical Dilution of Precision.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
GSA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = GSA(["GSA", "M", "3", "1", "2", "3", "1.2", "0.9", "1.5"])
```

"""
struct GSA <: NMEAString
    system::String
    mode::Char
    current_mode::Int
    sat_ids::Vector{Int}
    PDOP::Float64
    HDOP::Float64
    VDOP::Float64
    valid::Bool

    function GSA(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        sat_ids = Vector{Int}()
        for i = 4:length(items)-3
            if (items[i] |> strip |> isempty)
                break
            end
            push!(sat_ids, tryparse(Int, items[i]))
        end
        new(
            system,
            Char(items[2][1]),
            something(tryparse(Int, items[3]), 0),
            sat_ids,
            something(tryparse(Float64, items[end-2]), 0.0),
            something(tryparse(Float64, items[end-1]), 0.0),
            something(tryparse(Float64, items[end]), 0.0),
            valid,
        )
    end # constructor GSA
end # type GSA

"""
    struct ZDA <: NMEAString

Time and Date (ZDA)

This NMEA data type represents information about the current time and date from a GNSS receiver.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `day::Int`: Day of the month.
- `month::Int`: Month of the year.
- `year::Int`: Year.
- `zone_hrs::Int`: Time zone offset in hours.
- `zone_mins::Int`: Time zone offset in minutes.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
ZDA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = ZDA(["ZDA", "123456", "15", "02", "2024", "5", "30"])
```

"""
struct ZDA <: NMEAString
    system::String
    time::Float64
    day::Int
    month::Int
    year::Int
    zone_hrs::Int
    zone_mins::Int
    valid::Bool

    function ZDA(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Int, items[3]), 0),
            something(tryparse(Int, items[4]), 0),
            something(tryparse(Int, items[5]), 0),
            something(tryparse(Int, items[6]), 0),
            something(tryparse(Int, items[7]), 0),
            valid,
        )
    end # constructor ZDA

end # type ZDA

"""
    struct GBS <: NMEAString

GNSS Satellite Fault Detection (GBS)

This NMEA data type represents information about satellite fault detection, including error estimates
and probabilities.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `lat_error::Float64`: Latitude error estimate.
- `long_error::Float64`: Longitude error estimate.
- `alt_error::Float64`: Altitude error estimate.
- `failed_PRN::Int`: PRN of the failed satellite.
- `prob_of_missed::Float64`: Probability of missed detection.
- `excluded_meas_err::Float64`: Excluded measurement error.
- `standard_deviation::Float64`: Standard deviation of the measurements.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
GBS(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = GBS(["GBS", "123456", "0.1", "0.2", "0.3", "5", "0.01", "0.05", "0.02"])
```

"""
struct GBS <: NMEAString
    system::String
    time::Float64
    lat_error::Float64
    long_error::Float64
    alt_error::Float64
    failed_PRN::Int
    prob_of_missed::Float64
    excluded_meas_err::Float64
    standard_deviation::Float64
    valid::Bool

    function GBS(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            something(tryparse(Float64, items[4]), 0.0),
            something(tryparse(Float64, items[5]), 0.0),
            something(tryparse(Int, items[6]), 0),
            something(tryparse(Float64, items[7]), 0.0),
            something(tryparse(Float64, items[8]), 0.0),
            something(tryparse(Float64, items[9]), 0.0),
            valid,
        )
    end # constructor GBS
end # type GBS

"""
    struct GLL <: NMEAString

Geographic Latitude and Longitude (GLL)

This NMEA data type represents information about geographic latitude and longitude.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `latitude::Float64`: Latitude in decimal degrees.
- `longitude::Float64`: Longitude in decimal degrees.
- `time::Float64`: Time in seconds.
- `status::Bool`: Status indicator (true if valid fix, false otherwise).
- `mode::Char`: Mode indicator ('A' for autonomous mode).
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
GLL(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = GLL(["GLL", "12.3456", "N", "98.7654", "W", "123456", "A"])
```

"""
struct GLL <: NMEAString
    system::String
    latitude::Float64
    longitude::Float64
    time::Float64
    status::Bool
    mode::Char
    valid::Bool

    function GLL(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _dms_to_dd(items[2], items[3]),
            _dms_to_dd(items[4], items[5]),
            _hms_to_secs(items[6]),
            items[7] == "A" ? true : false,
            items[8] != "" ? Char(items[8][1]) : 'N',
            valid,
        )
    end # constructor GLL
end # type GLL

struct SVData <: NMEAString
    PRN::Int
    elevation::Int
    azimuth::Int
    SNR::Int
end # type SVData
"""
    struct GSV <: NMEAString

Satellites in View (GSV)

This NMEA data type represents information about the satellites in view and their signal strength.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `msg_total::Int`: Total number of GSV messages for this cycle.
- `msg_num::Int`: Number of this GSV message.
- `sat_total::Int`: Total number of satellites in view.
- `SV_data::Vector{SVData}`: Vector of satellite data, each containing PRN, elevation, azimuth, and SNR.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
GSV(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = GSV(["GSV", "3", "1", "9", "1", "01", "30", "45", "20", "02", "60", "180", "25", "03", "15", "300", "15"])
```

"""
struct GSV <: NMEAString
    system::String
    msg_total::Int
    msg_num::Int
    sat_total::Int
    SV_data::Vector{SVData}
    valid::Bool

    function GSV(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            something(tryparse(Int, items[2]), 0),
            something(tryparse(Int, items[3]), 0),
            something(tryparse(Int, items[4]), 0),
            [
                SVData(
                    something(tryparse(Int, items[i]), 0),
                    something(tryparse(Int, items[i+1]), 0),
                    something(tryparse(Int, items[i+2]), 0),
                    something(tryparse(Int, items[i+3]), 0),
                ) for i = 5:4:length(items)-4
            ],
            valid,
        )
    end # constructor GSV
end # type GSV

"""
    struct RMC <: NMEAString

Recommended Minimum Navigation Information (RMC)

This NMEA data type represents recommended minimum navigation information.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `status::Bool`: Status indicator (true if valid fix, false otherwise).
- `latitude::Float64`: Latitude in decimal degrees.
- `longitude::Float64`: Longitude in decimal degrees.
- `sog::Float64`: Speed over ground in knots.
- `cog::Float64`: Course over ground in degrees.
- `day::String`: Day of the month.
- `month::String`: Month of the year.
- `year::String`: Year.
- `magvar::Float64`: Magnetic variation.
- `mode::Char`: Mode indicator ('A' for autonomous mode).
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
RMC(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = RMC(["RMC", "123456", "A", "12.3456", "N", "98.7654", "W", "5.0", "90.0", "150225", "5.0", "W", "A"])
```

"""
struct RMC <: NMEAString
    system::String
    time::Float64
    status::Bool
    latitude::Float64
    longitude::Float64
    sog::Float64
    cog::Float64
    day::String
    month::String
    year::String
    magvar::Float64
    mode::Char
    valid::Bool

    function RMC(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            items[3] == "A",
            _dms_to_dd(items[4], items[5]),
            _dms_to_dd(items[6], items[7]),
            something(tryparse(Float64, items[8]), 0.0),
            something(tryparse(Float64, items[9]), 0.0),
            String(items[10][1:2]),
            String(items[10][3:4]),
            String(items[10][5:6]),
            something(
                (items[12] == "W" || items[12] == "S") ?
                (tryparse(Float64, items[11]) * -1) : (tryparse(Float64, items[11])),
                0.0,
            ),
            Char(items[3][1]),
            valid,
        )
    end # constructor RMC
end # type RMC

"""
    struct VTG <: NMEAString

Track Made Good and Ground Speed (VTG)

This NMEA data type represents information about the track made good (course) and ground speed.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `CoG_true::Float64`: Course over ground in true degrees.
- `CoG_mag::Float64`: Course over ground in magnetic degrees.
- `SoG_knots::Float64`: Speed over ground in knots.
- `SoG_kmhr::Float64`: Speed over ground in kilometers per hour.
- `mode::Char`: Mode indicator ('A' for autonomous mode).
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
VTG(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = VTG(["VTG", "90.0", "T", "45.0", "M", "5.0", "K", "A"])
```

"""
struct VTG <: NMEAString
    system::String
    CoG_true::Float64
    CoG_mag::Float64
    SoG_knots::Float64
    SoG_kmhr::Float64
    mode::Char
    valid::Bool

    function VTG(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            something(tryparse(Float64, items[2]), 0.0),
            something(tryparse(Float64, items[4]), 0.0),
            something(tryparse(Float64, items[6]), 0.0),
            something(tryparse(Float64, items[8]), 0.0),
            Char(items[10][1]),
            valid,
        )
    end # constructor VTG

end # type VTG

"""
    struct DTM <: NMEAString

Datum Reference (DTM)

This NMEA data type represents information about a datum reference.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `local_datum_code::String`: Local datum code.
- `local_datum_subcode::String`: Local datum subcode.
- `lat_offset::Float64`: Latitude offset in meters.
- `long_offset::Float64`: Longitude offset in meters.
- `alt_offset::Float64`: Altitude offset in meters.
- `ref_datum::String`: Reference datum.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
DTM(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = DTM(["DTM", "W84", "W", "0.5", "W", "1.0", "M", "W84"])
```

"""
struct DTM <: NMEAString
    system::String
    local_datum_code::String
    local_datum_subcode::String
    lat_offset::Float64
    long_offset::Float64
    alt_offset::Float64
    ref_datum::String
    valid::Bool

    function DTM(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            String(items[2]),
            String(items[3]),
            items[5] == "S" ? something(tryparse(Float64, items[4]), 0.0) * -1 :
            something(tryparse(Float64, items[4]), 0.0),
            items[7] == "W" ? something(tryparse(Float64, items[6]), 0.0) * -1 :
            something(tryparse(Float64, items[6]), 0.0),
            something(tryparse(Float64, items[8]), 0.0),
            String(items[9]),
            valid,
        )
    end # constructor DTM
end # type DTM

"""
    struct PASHR <: NMEAString

Inertial Attitude Data (PASHR)

This NMEA data type represents inertial attitude data, including heading, roll, pitch, and heave.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `heading::Float64`: Heading in decimal degrees.
- `heading_type::Bool`: True heading indicator (true if heading is relative to true north).
- `roll::Float64`: Roll in decimal degrees.
- `pitch::Float64`: Pitch in decimal degrees.
- `heave::Float64`: Heave in meters.
- `roll_accuracy::Float64`: Roll accuracy (standard deviation in decimal degrees).
- `pitch_accuracy::Float64`: Pitch accuracy (standard deviation in decimal degrees).
- `heading_accuracy::Float64`: Heading accuracy (standard deviation in decimal degrees).
- `aiding_code::Int`: GPS Update Quality Flag (0 = No position, 1 = Non-RTK fixed, 2 = RTK fixed).
- `ins_code::Int`: INS Status Flag (0 = Pre-Alignment, 1 = Post-Alignment).
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PASHR(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PASHR(["PASHR", "123456", "45.0", "T", "15.0", "-10.0", "2.0", "0.1", "0.1", "0.2", "2", "1"])
```

"""
struct PASHR <: NMEAString
    # Inertial attitude data
    # $PASHR,Time[hhmmss.sss],Heading[decimal degrees],True Heading[T displayed if heading is relative to true north.],Roll[decimal degrees],Pitch[decimal degrees],Heave[meters],Roll Accuracy,Pitch Accuracy,Headding Accuracy,GPS Update Quality Flag,INS Status Flag*CHECKSUM
    # Heading: The heading is the inertial azimuth calculated from the IMU gyros and the SPAN filters.
    # Accuracy: standard deviation in decimal degrees
    # GPS Update Quality Flag: [0 = No position, 1 = All non-RTK fixed integer positions, 2 = RTK fixed integer position]
    # INS Status Flag: [0 = All SPAN Pre-Alignment INS Status, 1 = All SPAN Post-Alignment INS Status (INS_ALIGNMENT_COMPLETE, INS_SOLUTION_GOOD, INS_HIGH_VARIANCE, INS_SOLUTION_FREE)]
    system::String
    time::Float64
    heading::Float64
    heading_type::Bool
    roll::Float64
    pitch::Float64
    heave::Float64
    roll_accuracy::Float64
    pitch_accuracy::Float64
    heading_accuracy::Float64
    aiding_code::Int
    ins_code::Int
    valid::Bool

    function PASHR(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            items[4] == "T" ? true : false,
            something(tryparse(Float64, items[5]), 0.0),
            something(tryparse(Float64, items[6]), 0.0),
            something(tryparse(Float64, items[7]), 0.0),
            something(tryparse(Float64, items[8]), 0.0),
            something(tryparse(Float64, items[9]), 0.0),
            something(tryparse(Float64, items[10]), 0.0),
            something(tryparse(Int, items[11]), 0),
            length(items) > 11 ? something(tryparse(Int, items[12]), 0) : 0,
            valid,
        )
    end

end # type PASHR

"""
    struct PTWPOS <: NMEAString

Position (PTWPOS)

This NMEA data type represents position information.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `xpose::Float64`: X position in meters.
- `ypose::Float64`: Y position in meters.
- `zpose::Float64`: Z position in meters.
- `distance::Float64`: Distance in meters.
- `velocity::Float64`: Velocity in kilometers per hour.
- `direction::Char`: Direction indicator ('F' for forward, 'B' for backward).
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PTWPOS(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PTWPOS(["PTWPOS", "123456", "45.678", "M", "123.456", "M", "789.012", "M", "456.789", "M", "5.0", "K", "F"])
```

"""
struct PTWPOS <: NMEAString
    # Position
    # $PTWPOS,TIME,X,X_UNIT[Meters],Y,Y_UNIT[Meters],Z,Z_UNIT[Meters],DISTANCE,D_UNIT[Meters],SPEED,S_UNIT[Kilometers per hour],DIRECTION[Forward/Backward]*CHECKSUM
    system::String
    time::Float64
    xpose::Float64
    ypose::Float64
    zpose::Float64
    distance::Float64
    velocity::Float64
    direction::Char
    valid::Bool

    function PTWPOS(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            pos_convert(only(items[4]), something(tryparse(Float64, items[3]), 0.0)),
            pos_convert(only(items[6]), something(tryparse(Float64, items[5]), 0.0)),
            pos_convert(only(items[8]), something(tryparse(Float64, items[7]), 0.0)),
            pos_convert(only(items[10]), something(tryparse(Float64, items[9]), 0.0)),
            vel_convert(only(items[12]), something(tryparse(Float64, items[11]), 0.0)),
            Char(only(items[13])),
            valid,
        )
    end # constructor PTWPOS
end # type PTWPOS


"""
    struct PTWVCT <: NMEAString

Movement Vector (PTWVCT)

This NMEA data type represents movement vector information.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `distance_derivative::Float64`: Distance derivative in meters.
- `heading::Float64`: Heading in radians.
- `distance::Float64`: Distance in meters.
- `speed::Float64`: Speed in meters per second.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PTWVCT(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PTWVCT(["PTWVCT", "123456", "2.0", "M", "1.5708", "R", "5.0", "M"])
```

"""
struct PTWVCT <: NMEAString
    # Movement Vector
    # $PTWVCT,TIME,DISTANCE_DERIVATIVE,DD_UNIT[Meters],HEADING,H_UNIT[Radians],DISTANCE,D_UNIT[Meters],SPEED, S_UNIT[Meters Per Second]*CHECKSUM
    system::String
    time::Float64
    distance_derivative::Float64
    heading::Float64
    distance::Float64
    speed::Float64
    valid::Bool

    function PTWVCT(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            pos_convert(only(items[4]), something(tryparse(Float64, items[3]), 0.0)),
            orientation_convert(
                only(items[6]),
                something(tryparse(Float64, items[5]), 0.0),
            ),
            pos_convert(only(items[8]), something(tryparse(Float64, items[7]), 0.0)),
            vel_convert(only(items[10]), something(tryparse(Float64, items[9]), 0.0)),
            valid,
        )
    end # constructor PTWVCT
end # type PTWVCT


"""
    struct PTWPLS <: NMEAString

Position in Pulses (PTWPLS)

This NMEA data type represents position information in pulses.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `x::Float64`: X position in pulses.
- `y::Float64`: Y position in pulses.
- `heading::Float64`: Heading in degrees.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PTWPLS(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PTWPLS(["PTWPLS", "123456", "500", "P", "750", "P", "90.0", "D"])
```

"""
struct PTWPLS <: NMEAString
    # Position in pulses
    # $PTWPLS,TIME,X,X_UNIT[Pulses],Y,Y_UNIT[Pulses],HEADING,H_UNIT[Degrees]*CHECKSUM
    system::String
    time::Float64
    x::Float64
    y::Float64
    heading::Float64
    valid::Bool

    function PTWPLS(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            something(tryparse(Float64, items[5]), 0.0),
            orientation_convert(
                only(items[8]),
                something(tryparse(Float64, items[7]), 0.0),
            ),
            valid,
        )
    end # constructor PTWPLS
end # type PTWPLS

"""
    struct PTWWHE <: NMEAString

Wheels Information (PTWWHE)

This NMEA data type represents wheels information.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `lw_pulses::Float64`: Left wheel pulses.
- `lw_distance::Float64`: Left wheel distance in meters.
- `lw_direction::Char`: Left wheel direction indicator ('F' for forward, 'B' for backward).
- `rw_pulses::Float64`: Right wheel pulses.
- `rw_distance::Float64`: Right wheel distance in meters.
- `rw_direction::Char`: Right wheel direction indicator ('F' for forward, 'B' for backward).
- `heading::Float64`: Heading.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PTWWHE(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PTWWHE(["PTWWHE", "123456", "500", "100.0", "M", "F", "750", "150.0", "M", "B", "90.0"])
```

"""
struct PTWWHE <: NMEAString
    # Wheels information
    # $PTWWHE,TIME,LEFT_WHEEL_PULSES,LW_DISTANCE,LWD_UNIT[Meters],LW_DIRECTION[Forward/Backward],RIGHT_WHEEL_PULSES,RW_DISTANCE,RWD_UNIT[Meters],RW_DIRECTION[Forward/Backward],HEADING*CHECKSUM
    system::String
    time::Float64
    lw_pulses::Float64
    lw_distance::Float64
    lw_direction::Char
    rw_pulses::Float64
    rw_distance::Float64
    rw_direction::Char
    heading::Float64
    valid::Bool

    function PTWWHE(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            pos_convert(only(items[5]), something(tryparse(Float64, items[4]), 0.0)),
            Char(only(items[6])),
            something(tryparse(Float64, items[7]), 0.0),
            pos_convert(only(items[9]), something(tryparse(Float64, items[8]), 0.0)),
            Char(only(items[10])),
            something(tryparse(Float64, items[11]), 0.0),
            valid,
        )
    end # constructor PTWWHE
end # type PTWWHE

"""
    struct PTWHPR <: NMEAString

IMU Heading Pitch Roll (PTWHPR)

This NMEA data type represents inertial measurement unit (IMU) information, including heading, pitch, and roll.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `heading::Float64`: Heading in degrees.
- `pitch::Float64`: Pitch in degrees.
- `roll::Float64`: Roll in degrees.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PTWHPR(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PTWHPR(["PTWHPR", "123456", "90.0", "30.0", "-45.0"])
```

"""
struct PTWHPR <: NMEAString
    # IMU heading pitch roll
    # $PTWHPR,HEADING,PITCH,ROLL*CHECKSUM
    system::String
    time::Float64
    heading::Float64
    pitch::Float64
    roll::Float64
    valid::Bool

    function PTWHPR(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            something(tryparse(Float64, items[4]), 0.0),
            something(tryparse(Float64, items[5]), 0.0),
            valid,
        )
    end # constructor PTWHPR
end # type PTWHPR


"""
    struct PTACC <: NMEAString

IMU Accelerometer (PTACC)

This NMEA data type represents inertial measurement unit (IMU) accelerometer information.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `x::Float64`: Acceleration in the X-axis.
- `y::Float64`: Acceleration in the Y-axis.
- `z::Float64`: Acceleration in the Z-axis.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PTACC(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PTACC(["PTACC", "123456", "0.5", "1.0", "-0.2"])
```

"""
struct PTACC <: NMEAString
    # IMU accelerometer
    # $PTACC,ACC_X,ACC_Y,ACC_Z*CHECKSUM
    system::String
    time::Float64
    x::Float64
    y::Float64
    z::Float64
    valid::Bool

    function PTACC(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            something(tryparse(Float64, items[4]), 0.0),
            something(tryparse(Float64, items[5]), 0.0),
            valid,
        )
    end # constructor PTACC
end # type PTACC


"""
    struct PTGYR <: NMEAString

IMU Gyroscope (PTGYR)

This NMEA data type represents inertial measurement unit (IMU) gyroscope information.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `x::Float64`: Angular velocity around the X-axis.
- `y::Float64`: Angular velocity around the Y-axis.
- `z::Float64`: Angular velocity around the Z-axis.
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
PTGYR(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
data = PTGYR(["PTGYR", "123456", "0.1", "-0.2", "0.5"])
```

"""
struct PTGYR <: NMEAString
    # IMU gyroscope
    # $PTGYR,GYR_X,GYR_Y,GYR_Z*CHECKSUM
    system::String
    time::Float64
    x::Float64
    y::Float64
    z::Float64
    valid::Bool

    function PTGYR(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            something(tryparse(Float64, items[4]), 0.0),
            something(tryparse(Float64, items[5]), 0.0),
            valid,
        )
    end # constructor PTGYR
end # type PTGYR
