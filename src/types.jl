abstract type NMEAString end

"""
    GGA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true)

A struct that represents a Global Positioning System Fix Data (GGA) sentence from the NMEA protocol.
It contains information about the GPS system, time, location, fix quality, number of satellites,
horizontal dilution of precision (HDOP), altitude, geoidal separation, age of differential corrections,
and differential reference station ID.

# Arguments
- `items::Array{D}`: An array of strings that contains the fields of the GGA sentence, separated by commas.
- `system::AbstractString`: An optional keyword argument that specifies the type of GPS system used.
    It can be "GPS", "GLONASS", "GALILEO", or "Combined". The default value is "UNKNOWN".
- `valid::Bool`: An optional keyword argument that indicates whether the GGA sentence is valid or not. The default value is true.

# Returns
- A `GGA` object with the following fields:
    - `system::String`: The type of GPS system used.
    - `time::Float64`: The UTC time of the fix in seconds.
    - `latitude::Float64`: The latitude of the position in decimal degrees.
    - `longitude::Float64`: The longitude of the position in decimal degrees.
    - `fix_quality::String`: The quality of the fix. It can be one of the following values:
        "INVALID", "GPS (SPS)", "DGPS", "PPS", "REAL TIME KINEMATIC", "FLOAT RTK",
        "DEAD RECKONING", "MANUAL INPUT", or "SIMULATION".
    - `num_sats::Int`: The number of satellites used in the fix.
    - `HDOP::Float64`: The horizontal dilution of precision (HDOP) of the fix.
    - `altitude::Float64`: The altitude above mean sea level (MSL) in meters.
    - `geoidal_seperation::Float64`: The difference between the WGS-84 earth ellipsoid and mean sea level (MSL) in meters.
    - `age_of_differential::Float64`: The time since the last SC104 type 1 or 9 update in seconds.
        A value of 0 means no differential GPS correction is available.
    - `diff_reference_id::Int`: The differential reference station ID.
    - `valid::Bool`: Whether the GGA sentence is valid or not.

The GGA sentence is one of the most common sentences used with GPS receivers.
It contains information about position, elevation, time, number of satellites used, fix type, and correction age.
The message ID for the GGA sentence is “GGA”. Here is an example of a GGA sentence:

`\$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47`

This means that the GPS receiver reported its position as 48 degrees 7.038 minutes north latitude and 11 degrees 31.000 minutes east longitude at 12:35:19 UTC on the current date.
The fix type was GPS (SPS), with 8 satellites used and a horizontal dilution of precision (HDOP) of 0.9.
The altitude above mean sea level (MSL) was 545.4 meters, and the geoidal separation was 46.9 meters
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

    function GGA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
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
        new(system,
            _hms_to_secs(items[2]),
            _dms_to_dd(items[3], items[4]),
            _dms_to_dd(items[5], items[6]),
            fix_quality,
            something(tryparse(Int, items[8]),0),
            something(tryparse(Float64, items[9]),0.0),
            something(tryparse(Float64, items[10]),0.0),
            something(tryparse(Float64, items[12]),0.0),
            something(tryparse(Float64, items[14]),0.0),
            something(tryparse(Int, items[15]),0),
            valid
            )
    end # constructor GGA

end # type GGA

"""
    GSA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true)

A struct that represents a GNSS DOP and Active Satellites (GSA) sentence from the NMEA protocol.
It contains information about the GPS system, mode, current mode, satellite IDs,
position dilution of precision (PDOP), horizontal dilution of precision (HDOP), and vertical dilution of precision (VDOP).

# Arguments
- `items::Array{D}`: An array of strings that contains the fields of the GSA sentence, separated by commas.
- `system::AbstractString`: An optional keyword argument that specifies the type of GPS system used.
It can be "GPS", "GLONASS", "GALILEO", or "Combined". The default value is "UNKNOWN".
- `valid::Bool`: An optional keyword argument that indicates whether the GSA sentence is valid or not. The default value is true.

# Returns
- A `GSA` object with the following fields:
    - `system::String`: The type of GPS system used.
    - `mode::Char`: The mode of operation. It can be 'A' for automatic or 'M' for manual.
    - `current_mode::Int`: The current mode of operation. It can be one of the following values: 1 for no fix, 2 for 2D fix, or 3 for 3D fix.
    - `sat_ids::Vector{Int}`: A vector of integers that contains the IDs of the satellites used in the fix.
    - `PDOP::Float64`: The position dilution of precision (PDOP) of the fix.
    - `HDOP::Float64`: The horizontal dilution of precision (HDOP) of the fix.
    - `VDOP::Float64`: The vertical dilution of precision (VDOP) of the fix.
    - `valid::Bool`: Whether the GSA sentence is valid or not.

The GSA sentence contains information about the GNSS DOP and active satellites.
It indicates the mode of operation, the current mode of operation, the satellite IDs used in the fix,
and the position dilution of precision (PDOP), horizontal dilution of precision (HDOP), and vertical dilution of precision (VDOP).
The message ID for the GSA sentence is “GSA”. Here is an example of a GSA sentence:

`\$GNGSA,A,3,21,5,29,25,12,10,26,2,,,,,1.2,0.7,1.0*27`

This means that the GNSS receiver was in automatic mode and had a 3D fix using satellites with IDs 21, 5, 29, 25, 12, 10, 26, and 2.
The PDOP was 1.2, the HDOP was 0.7, and the VDOP was 1.0
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

    function GSA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        sat_ids = Vector{Int}()
        for i = 4:length(items) - 3
            if (items[i] |> strip |> isempty)
                break
            end
            push!(sat_ids, tryparse(Int, items[i]))
        end
        new(system,
            Char(items[2][1]),
            something(tryparse(Int, items[3]),0),
            sat_ids,
            something(tryparse(Float64, items[end - 2]),0.0),
            something(tryparse(Float64, items[end - 1]),0.0),
            something(tryparse(Float64, items[end]),0.0),
            valid)
    end # constructor GSA
end # type GSA

"""
    ZDA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true)

A struct that represents a Time and Date (ZDA) sentence from the NMEA protocol. It contains information about the GPS system, time, date, and local time zone.

# Arguments
- `items::Array{D}`: An array of strings that contains the fields of the ZDA sentence, separated by commas.
- `system::AbstractString`: An optional keyword argument that specifies the type of GPS system used. It can be "GPS", "GLONASS", "GALILEO", or "Combined". The default value is "UNKNOWN".
- `valid::Bool`: An optional keyword argument that indicates whether the ZDA sentence is valid or not. The default value is true.

# Returns
- A `ZDA` object with the following fields:
    - `system::String`: The type of GPS system used.
    - `time::Float64`: The UTC time of the fix in seconds.
    - `day::Int`: The day of the month (1-31).
    - `month::Int`: The month of the year (1-12).
    - `year::Int`: The year (four digits).
    - `zone_hrs::Int`: The local time zone offset from UTC in hours.
    - `zone_mins::Int`: The local time zone offset from UTC in minutes.
    - `valid::Bool`: Whether the ZDA sentence is valid or not.

An example of a ZDA sentence is:

`\$GPZDA,201530.00,04,07,2002,00,00*60`

This means that the GPS system reported the date and time as 20:15:30.00 UTC on July 4th, 2002, with no local time zone offset1.

The purpose of the ZDA sentence is to provide a reliable and accurate source of date and time information for applications that require synchronization or logging.
For example, some scientific instruments or sensors may need to record the exact time of their measurements or events.
The ZDA sentence can also be used to adjust the internal clock of the receiver or other devices
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

    function ZDA(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        new(system,
        _hms_to_secs(items[2]),
        something(tryparse(Int, items[3]),0),
        something(tryparse(Int, items[4]),0),
        something(tryparse(Int, items[5]),0),
        something(tryparse(Int, items[6]),0),
        something(tryparse(Int, items[7]),0),
        valid)
    end # constructor ZDA

end # type ZDA

"""
    GBS(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true)

A struct that represents a GBS NMEA string, which is a message that contains
the error estimates of the position fix from a global navigation satellite system (GNSS).

# Fields
- `system::String`: The name of the system that produced the message.
- `time::Float64`: The time of the message in seconds since midnight UTC.
- `lat_error::Float64`: The expected error in latitude in meters.
- `long_error::Float64`: The expected error in longitude in meters.
- `alt_error::Float64`: The expected error in altitude in meters.
- `failed_PRN::Int`: The pseudo-random noise (PRN) number of the satellite that has failed or is likely to fail.
- `prob_of_missed::Float64`: The probability of missed detection for the failed satellite.
- `excluded_meas_err::Float64`: The estimated error caused by excluding the measurement from the failed satellite.
- `standard_deviation::Float64`: The standard deviation of the residual errors for all satellites used in the position fix.
- `valid::Bool`: A flag that indicates whether the message is valid or not.

# Constructor
The constructor takes an array of strings as an argument, which are the items in
the GBS NMEA string. It also takes optional keyword arguments for the system name
and the validity flag. It parses the items and assigns them to the corresponding fields.
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

    function GBS(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        new(system,
        _hms_to_secs(items[2]),
        something(tryparse(Float64, items[3]),0.0),
        something(tryparse(Float64, items[4]),0.0),
        something(tryparse(Float64, items[5]),0.0),
        something(tryparse(Int, items[6]),0),
        something(tryparse(Float64, items[7]),0.0),
        something(tryparse(Float64, items[8]),0.0),
        something(tryparse(Float64, items[9]),0.0),
        valid,
        )
    end # constructor GBS
end # type GBS

"""
    GLL <: NMEAString

A struct for handling NMEA message data of type GLL, which contains geographic position and time information.

# Fields

- `system::String`: the name of the GNSS system that produced the data (e.g. "GPS", "GLONASS", etc.)
- `latitude::Float64`: the latitude of the position in decimal degrees
- `longitude::Float64`: the longitude of the position in decimal degrees
- `time::Float64`: the UTC time of the position in seconds
- `status::Bool`: whether the position is valid (`true`) or not (`false`)
- `mode::Char`: the mode indicator of the position fix (e.g. 'A' for autonomous, 'D' for differential, etc.)
- `valid::Bool`: whether the message data is valid (`true`) or not (`false`)

# Constructor

The constructor takes an array of strings as an argument, which should contain the fields of the GLL message in order, separated by commas.
Optionally, a keyword argument `system` can be given to specify the GNSS system name, and a keyword argument `valid` can be given to indicate the validity of the message data.
If not given, these arguments default to "UNKNOWN" and `true`, respectively.

The GLL message contains the latitude, longitude, time, and status of the position fix obtained by the receiver.
The status indicates whether the position is valid or not, and the mode indicates whether the position is obtained autonomously, differentially, or by other means.
The GLL message is useful for applications that need to know the exact location and time of the receiver.
"""
struct GLL <: NMEAString
    system::String
    latitude::Float64
    longitude::Float64
    time::Float64
    status::Bool
    mode::Char
    valid::Bool

    function GLL(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        new(system,
            _dms_to_dd(items[2], items[3]),
            _dms_to_dd(items[4], items[5]),
            _hms_to_secs(items[6]),
            items[7] == "A" ? true : false,
            items[8] != "" ? Char(items[8][1]) : 'N',
            valid)
    end # constructor GLL
end # type GLL

"""
    SVData <: NMEAString

A struct for handling NMEA message data of type SVData, which contains information about one satellite in view of a GNSS receiver.

# Fields

- `PRN::Int`: the PRN number of the satellite, which identifies it uniquely within its system
- `elevation::Int`: the elevation angle of the satellite in degrees, relative to the horizon
- `azimuth::Int`: the azimuth angle of the satellite in degrees, relative to the true north
- `SNR::Int`: the signal-to-noise ratio of the satellite in decibels, which measures the quality of the signal received from the satellite

The SVData struct is used to store and process information about one satellite that is in view of a GNSS receiver.
It is usually part of a GSV message, which contains information about all the satellites in view.
The SVData struct can be used to determine the availability and quality of the satellites that can be used for positioning.
"""
struct SVData <: NMEAString
    PRN::Int
    elevation::Int
    azimuth::Int
    SNR::Int
end # type SVData

"""
    GSV <: NMEAString

A struct for handling NMEA message data of type GSV, which contains information about the GNSS satellites in view.

# Fields

- `system::String`: the name of the GNSS system that produced the data (e.g. "GPS", "GLONASS", etc.)
- `msg_total::Int`: the total number of GSV messages in this cycle
- `msg_num::Int`: the sequence number of this message in this cycle
- `sat_total::Int`: the total number of satellites in view
- `SV_data::Vector{Int}`: an array of SVData structs, each containing information about one satellite in view
- `valid::Bool`: whether the message data is valid (`true`) or not (`false`)

# Constructor

The constructor takes an array of strings as an argument, which should contain the fields of the GSV message in order,
separated by commas. Optionally, a keyword argument `system` can be given to specify the GNSS system name,
and a keyword argument `valid` can be given to indicate the validity of the message data.
If not given, these arguments default to "UNKNOWN" and `true`, respectively.

The GSV message contains information about the satellites that are in view of the receiver,
such as their PRN numbers, elevations, azimuths, and signal-to-noise ratios.
The PRN number identifies the satellite uniquely within its system,
and the elevation and azimuth indicate the direction of the satellite relative to the receiver.
The signal-to-noise ratio measures the quality of the signal received from the satellite.
The GSV message is useful for applications that need to know the availability and quality of the satellites that can be used for positioning
"""
struct GSV <: NMEAString
    system::String
    msg_total::Int
    msg_num::Int
    sat_total::Int
    SV_data::Vector{SVData}
    valid::Bool

    function GSV(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
    new(system,
        something(tryparse(Int, items[2]),0),
        something(tryparse(Int, items[3]),0),
        something(tryparse(Int, items[4]),0),
        [SVData(
            something(tryparse(Int, items[i]),0),
            something(tryparse(Int, items[i + 1]),0),
            something(tryparse(Int, items[i + 2]),0),
            something(tryparse(Int, items[i + 3]),0)
            ) for i in 5:4:length(items)-4],
        valid)
    end # constructor GSV
end # type GSV

"""
    RMC <: NMEAString

A type that represents a Recommended Minimum Navigation Information (RMC) message,
which is one of the most common types of NMEA messages. NMEA stands for National Marine Electronics Association,
and it is a standard protocol for communication between marine electronic devices.
An RMC message provides information about the position, velocity, time, date, and magnetic variation of a GPS receiver.

# Fields
- `system::String`: The system identifier, indicating the source of the message (e.g. "GPS", "GLONASS", "UNKNOWN").
- `time::Float64`: The UTC time of the position fix, in seconds since midnight.
- `status::Bool`: The status indicator, either true for active or false for void (invalid).
- `latitude::Float64`: The latitude of the position, in decimal degrees.
- `longitude::Float64`: The longitude of the position, in decimal degrees.
- `sog::Float64`: The speed over ground, in knots.
- `cog::Float64`: The track angle, in degrees true (not magnetic).
- `day::String`: The day of the position fix, in two digits.
- `month::String`: The month of the position fix, in two digits.
- `year::String`: The year of the position fix, in two digits.
- `magvar::Float64`: The magnetic variation, in degrees. A negative value indicates west and a positive value indicates east.
- `mode::Char`: The mode indicator, indicating the type of fix. It can be one of the following values:
    - 'A' for autonomous (GPS only)
    - 'D' for differential (DGPS)
    - 'E' for estimated
    - 'F' for float RTK
    - 'M' for manual input
    - 'N' for no fix
    - 'P' for precise
    - 'R' for real time kinematic
    - 'S' for simulator
- `valid::Bool`: A flag indicating whether the message is valid or not.

# Constructor
The constructor takes an array of strings as an argument, which are the items of an RMC sentence.
It also takes an optional keyword argument `system`, which specifies the system identifier.
If not given, it defaults to "UNKNOWN". Another optional keyword argument is `valid`,
which specifies whether the message is valid or not. If not given, it defaults to true.
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

    function RMC(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        new(system,
            _hms_to_secs(items[2]),
            items[3] == "A",
            _dms_to_dd(items[4], items[5]),
            _dms_to_dd(items[6], items[7]),
            something(tryparse(Float64, items[8]),0.0),
            something(tryparse(Float64, items[9]),0.0),
            String(items[10][1:2]),
            String(items[10][3:4]),
            String(items[10][5:6]),
            something((items[12] == "W" || items[12] == "S") ? (tryparse(Float64, items[11]) * -1) : (tryparse(Float64, items[11])),0.0),
            Char(items[3][1]),
            valid)
    end # constructor RMC
end # type RMC

"""
    VTG <: NMEAString

A type that represents a Track made good and speed over ground (VTG) message,
which is one of the types of NMEA messages. NMEA stands for National Marine Electronics Association,
and it is a standard protocol for communication between marine electronic devices.
A VTG message provides information about the actual track made good and speed over ground of a GPS receiver.

# Fields
- `system::String`: The system identifier, indicating the source of the message (e.g. "GPS", "GLONASS", "UNKNOWN").
- `CoG_true::Float64`: The track made good (degrees true).
- `CoG_mag::Float64`: The track made good (degrees magnetic).
- `SoG_knots::Float64`: The speed over ground, in knots.
- `SoG_kmhr::Float64`: The speed over ground, in kilometers per hour (kph).
- `mode::Char`: The mode indicator, indicating the type of fix. It can be one of the following values:
    - 'A' for autonomous (GPS only)
    - 'D' for differential (DGPS)
    - 'E' for estimated (dead reckoning) mode
    - 'M' for manual input mode
    - 'S' for simulator mode
    - 'N' for data not valid
- `valid::Bool`: A flag indicating whether the message is valid or not.

# Constructor
The constructor takes an array of strings as an argument, which are the items of a VTG sentence.
It also takes an optional keyword argument `system`, which specifies the system identifier.
If not given, it defaults to "UNKNOWN". Another optional keyword argument is `valid`,
which specifies whether the message is valid or not. If not given, it defaults to true.

# Example
A message has the following format: `\$GPVTG,x.x,T,x.x,M,x.x,N,x.x,K,m*hh`


For example, the following VTG message:

`\$GPVTG,140.88,T,M,8.04,N,14.89,K,D*05`

Means that:

* The track made good is 140.88 degrees true.
* The track made good is not available in degrees magnetic.
* The speed over ground is 8.04 knots.
* The speed over ground is 14.89 kph.
* The mode indicator is differential (DGPS).
* The checksum data is 05.
"""
struct VTG <: NMEAString
    system::String
    CoG_true::Float64
    CoG_mag::Float64
    SoG_knots::Float64
    SoG_kmhr::Float64
    mode::Char
    valid::Bool

    function VTG(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        new(system,
            something(tryparse(Float64, items[2]),0.0),
            something(tryparse(Float64, items[4]),0.0),
            something(tryparse(Float64, items[6]),0.0),
            something(tryparse(Float64, items[8]),0.0),
            Char(items[10][1]),
            valid)
    end # constructor VTG

end # type VTG

"""
    DTM <: NMEAString

A type that represents a Datum reference (DTM) message, which is one of the types of NMEA messages.
NMEA stands for National Marine Electronics Association, and it is a standard protocol for communication between marine electronic devices.
A DTM message identifies the local geodetic datum and datum offsets from a reference datum.
This sentence is used to define the datum to which a position location, and geographic locations in subsequent sentences, is referenced[^1^][1].

# Fields
- `system::String`: The system identifier, indicating the source of the message (e.g. "GPS", "GLONASS", "UNKNOWN").
- `local_datum_code::String`: The local datum code (CCC), which can be one of the following values[^1^][1]:
    - W84 – WGS-84
    - W72 – WGS-72
    - S85 – SGS85
    - P90 – PE90
    - 999 – User-defined IHO datum code
- `local_datum_subcode::String`: The local datum subdivision code (x).
- `lat_offset::Float64`: The latitude offset, in minutes (x.x). A negative value indicates south and a positive value indicates north.
- `long_offset::Float64`: The longitude offset, in minutes (x.x). A negative value indicates west and a positive value indicates east.
- `alt_offset::Float64`: The altitude offset, in meters (x.x).
- `ref_datum::String`: The reference datum code (CCC), which can be one of the following values[^1^][1]:
    - W84 – WGS-84
    - W72 – WGS-72
    - S85 – SGS85
    - P90 – PE90
    - 999 – User-defined IHO datum code
- `valid::Bool`: A flag indicating whether the message is valid or not.

# Constructor
The constructor takes an array of strings as an argument, which are the items of a DTM sentence.
It also takes an optional keyword argument `system`, which specifies the system identifier.
If not given, it defaults to "UNKNOWN". Another optional keyword argument is `valid`,
which specifies whether the message is valid or not. If not given, it defaults to true.

# Example
`\$GPDTM,W84,,0.000000,N,0.000000,E,0.0,W84*6F`
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

    function DTM(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        new(system,
            String(items[2]),
            String(items[3]),
            items[5] == "S" ? something(tryparse(Float64, items[4]),0.0)*-1 : something(tryparse(Float64, items[4]),0.0),
            items[7] == "W" ? something(tryparse(Float64, items[6]),0.0)*-1 : something(tryparse(Float64, items[6]),0.0),
            something(tryparse(Float64, items[8]),0.0),
            String(items[9]),
            valid)
    end # constructor DTM
end # type DTM


"""
    PASHR(system, time, heading, heading_type, roll, pitch, heave, roll_accuracy,
          pitch_accuracy, heading_accuracy, aiding_code, ins_code, valid)

A struct that represents a PASHR NMEA string, which is a message that contains
position and attitude data from an inertial navigation system (INS).

# Fields
- `system::String`: The name of the system that produced the message.
- `time::Float64`: The time of the message in seconds since midnight UTC.
- `heading::Float64`: The heading angle in degrees clockwise from north.
- `heading_type::Char`: The type of heading: 'T' for true or 'M' for magnetic.
- `roll::Float64`: The roll angle in degrees. Positive values indicate right roll.
- `pitch::Float64`: The pitch angle in degrees. Positive values indicate nose up.
- `heave::Float64`: The heave displacement in meters. Positive values indicate upward motion.
- `roll_accuracy::Float64`: The standard deviation of the roll angle in degrees.
- `pitch_accuracy::Float64`: The standard deviation of the pitch angle in degrees.
- `heading_accuracy::Float64`: The standard deviation of the heading angle in degrees.
- `aiding_code::Int`: A code that indicates the type of aiding used by the INS.
- `ins_code::Int`: A code that indicates the status of the INS.
- `valid::Bool`: A flag that indicates whether the message is valid or not.

# Constructor
The constructor takes an array of strings as an argument, which are the items in
the PASHR NMEA string. It also takes optional keyword arguments for the system name
and the validity flag. It parses the items and assigns them to the corresponding fields.

# Example
`\$PASHR,154155.50,153.17,T,9.68,2.29,-0.07,0.502,0.502,0.959,1*19`
"""
struct PASHR <: NMEAString
    system::String
    time::Float64
    heading::Float64
    heading_type::String
    roll::Float64
    pitch::Float64
    heave::Float64
    roll_accuracy::Float64
    pitch_accuracy::Float64
    heading_accuracy::Float64
    aiding_code::Int
    ins_code::Int
    valid::Bool

    function PASHR(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        new(system,
            _hms_to_secs(items[2]),
            something(tryparse(Float64, items[3]), 0.0),
            items[4]=="T" ? "True" : "",
            something(tryparse(Float64, items[5]),0.0),
            something(tryparse(Float64, items[6]),0.0),
            something(tryparse(Float64, items[7]),0.0),
            something(tryparse(Float64, items[8]),0.0),
            something(tryparse(Float64, items[9]),0.0),
            something(tryparse(Float64, items[10]),0.0),
            something(tryparse(Int,items[11]),0),
            length(items)>11 ? something(tryparse(Int,items[12]),0) : 0,
            valid)
    end

end # type PASHR

"""
    TWPOS(system, time, xpose, ypose, zpose, distance, velocity, valid)

A struct that represents a TWPOS NMEA string, which is a message that contains
the position and velocity data from a transponder.

# Fields
- `system::String`: The name of the system that produced the message.
- `time::Float64`: The time of the message in seconds since midnight UTC.
- `xpose::Float64`: The x-coordinate of the position in meters.
- `ypose::Float64`: The y-coordinate of the position in meters.
- `zpose::Float64`: The z-coordinate of the position in meters.
- `distance::Float64`: The distance from the origin in meters.
- `velocity::Float64`: The velocity in meters per second.
- `valid::Bool`: A flag that indicates whether the message is valid or not.

# Constructor
The constructor takes an array of strings as an argument, which are the items in
the TWPOS NMEA string. It also takes optional keyword arguments for the system name
and the validity flag. It parses the items and converts them to the appropriate units
and assigns them to the corresponding fields.
"""
struct TWPOS <: NMEAString
    system::String
    time::Float64
    xpose::Float64
    ypose::Float64
    zpose::Float64
    distance::Float64
    velocity::Float64
    valid::Bool

    function TWPOS(items::Array{D}; system::AbstractString = "UNKNOWN", valid = true) where D <: SubString
        # Todo check second value for unit (M == meter, K == kilometer, F == feet, N == miles)
        # and update accordingly to meters
        # f /= 0.3048 n *= 0.621371192237 k *= 1000
        new(system,
            _hms_to_secs(items[2]),
            pos_convert(only(items[4]), something(tryparse(Float64, items[3]),0.0)),
            pos_convert(only(items[6]), something(tryparse(Float64, items[5]),0.0)),
            pos_convert(only(items[8]), something(tryparse(Float64, items[7]),0.0)),
            pos_convert(only(items[10]), something(tryparse(Float64, items[9]),0.0)),
            vel_convert(only(items[12]), something(tryparse(Float64, items[11]),0.0)),
            valid)
    end # constructor TWPOS
end # type TWPOS
