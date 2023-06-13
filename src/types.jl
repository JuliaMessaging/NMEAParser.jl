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
            _hms_to_secs(items, 2),
            _dms_to_dd(items[3], items[4]),
            _dms_to_dd(items[5], items[6]),
            fix_quality,
            _to_int(items, 8),
            _to_float(items, 9),
            _to_float(items, 10),
            _to_float(items, 12),
            _to_float(items, 14),
            _to_int(items, 15),
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
        new(
            system,
            Char(items[2][1]),
            _to_int(items, 3),
            map(_to_int, items[4:end-3]),
            _to_float(items[end-2]),
            _to_float(items[end-1]),
            _to_float(items[end]),
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
            _hms_to_secs(items, 2),
            _to_int(items, 3),
            _to_int(items, 4),
            _to_int(items, 5),
            _to_int(items, 6),
            _to_int(items, 7),
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
            _hms_to_secs(items, 2),
            _to_float(items, 3),
            _to_float(items, 4),
            _to_float(items, 5),
            _to_int(items, 6),
            _to_float(items, 7),
            _to_float(items, 8),
            _to_float(items, 9),
            valid,
        )
    end # constructor GBS
end # type GBS

"""
    struct GST <: NMEAString

Position error statistics.

# Fields
- `system::String`: GNSS system identifier (e.g., GPS, GLONASS, GALILEO, Combined).
- `time::Float64`: Time in seconds.
- `rms::Float64`: RMS value of the pseudorange residuals; includes carrier phase residuals during periods of RTK (float) and RTK (fixed) processing
- `semi_major_error::Float64`: Error ellipse semi-major axis 1-sigma error, in meters
- `semi_minor_error::Float64`: Error ellipse semi-minor axis 1-sigma error, in meters
- `orientation_error::Float64`: Error ellipse orientation, degrees from true north
- `latitude_error::Float64`: Latitude 1-sigma error, in meters
- `longitude_error::Float64`: Longitude 1-sigma error, in meters
- `height_error::Float64`: Height 1-sigma error, in meters
- `valid::Bool`: Flag indicating the validity of the data.

Example String: \$GPGST,172814.0,0.006,0.023,0.020,273.6,0.023,0.020,0.031*6A
"""
struct GST <: NMEAString
    system::String
    time::Float64
    rms::Float64
    semi_major_error::Float64
    semi_minor_error::Float64
    orientation_error::Float64
    latitude_error::Float64
    longitude_error::Float64
    height_error::Float64
    valid::Bool

    function GST(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where { D <: SubString }
        new(
            system,
            _hms_to_secs(items, 2),
            _to_float(items, 3),
            _to_float(items, 4),
            _to_float(items, 5),
            _to_float(items, 6),
            _to_float(items, 7),
            _to_float(items, 8),
            _to_float(items, 9),
            valid
        )
    end # constructor GST
end # type GST

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
            _to_int(items, 2),
            _to_int(items, 3),
            _to_int(items, 4),
            [
                SVData(
                    _to_int(items, i),
                    _to_int(items, i+1),
                    _to_int(items, i+2),
                    _to_int(items, i+3),
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
- `time::Float64`: Time in seconds of position fix.
- `status::Bool`: Status indicator (true if active, false otherwise/void).
- `latitude::Float64`: Latitude in decimal degrees.
- `longitude::Float64`: Longitude in decimal degrees.
- `sog::Float64`: Speed over ground in knots.
- `cog::Float64`: track angle over ground in degrees.
- `date::Date`: Day of the month.
- `month::String`: Month of the year.
- `year::String`: Year.
- `magvar::Float64`: Magnetic variation.
- `mode::Char`: Position system mode indicator (D=differential,A=autonomous,N=not valid,E=estimated/dead reckoning, M=manual input).
- `navstatus::Char`: Navigational status. (S = Safe, C = Caution, U = Unsafe, V = Navigational status not valid).
- `valid::Bool`: Flag indicating the validity of the data.

# Constructor
```julia
RMC(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
```

# Examples
```julia
nmeastr = "\$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A"
data = RMC(["RMC", "123519", "A", "4807.038", "N", "01131.000", "E", "022.4", "084.4", "230394", "003.1", "W"], "GPS", true)

altstr = "\$GNRMC,060512.00,A,3150.788156,N,11711.922383,E,0.0,,311019,,,A,V*1B"
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
    navstatus::Char
    valid::Bool

    function RMC(
        items::Array{D};
        system::AbstractString = "UNKNOWN",
        valid = true,
    ) where {D<:SubString}
        new(
            system,
            _hms_to_secs(items, 2),
            get(items, 3, "V") == "A",
            _dms_to_dd(items, 4),
            _dms_to_dd(items, 6),
            _to_float(items, 8),
            _to_float(items, 9),
            String(items[10][1:2]),
            String(items[10][3:4]),
            String(items[10][5:6]),
            (_to_float(items, 11) * (in(get(items, 12, ""),("W","S")) ? -1.0 : 1.0)),
            only(get(items, 13, "N")),
            only(get(items, 14, "V")),
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
            _to_float(items, 2),
            _to_float(items, 4),
            _to_float(items, 6),
            _to_float(items, 8),
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
            items[5] == "S" ? _to_float(items, 4) * -1 : _to_float(items, 4),
            items[7] == "W" ? _to_float(items, 6) * -1 : _to_float(items, 6),
            _to_float(items, 8),
            String(items[9]),
            valid,
        )
    end # constructor DTM
end # type DTM
