using Test, Aqua, NMEAParser

Aqua.test_ambiguities([NMEAParser, Base, Core])
Aqua.test_unbound_args(NMEAParser)
Aqua.test_undefined_exports(NMEAParser)
Aqua.test_project_extras(NMEAParser)
Aqua.test_stale_deps(NMEAParser; ignore = [:Aqua])
# Aqua.test_deps_compat(NMEAParser)

@testset "nmea_parse NMEAParser.parse equivalency" begin
    msg = raw"$GPGGA,181908.00,3404.7041778,N,07044.3966270,W,4,13,1.00,495.144,M,29.200,M,0.10,0000*5f"
    nmea_parse_out = nmea_parse(msg)
    nmeaparser_parse_out = NMEAParser.parse(msg)
    @test nmea_parse_out === nmeaparser_parse_out 
end

@testset "Test with Data File: `parse_msg!` and `update!`" begin
    nmeas = NMEAData()
    open("testdata.txt", "r") do f
        while !eof(f)
            line = readline(f)

            mtype = NMEAParser.parse_msg!(nmeas, line)

            if (mtype == GGA)
                @test nmeas.last_GGA.valid
            elseif (mtype == RMC)
                @test nmeas.last_RMC.valid
            elseif (mtype == GSA)
                @test nmeas.last_GSA.valid
            elseif (mtype == GSV)
                @test nmeas.last_GSV.valid
            elseif (mtype == GST)
                @test nmeas.last_GST.valid
            elseif (mtype == GBS)
                @test nmeas.last_GBS.valid
            elseif (mtype == VTG)
                @test nmeas.last_VTG.valid
            elseif (mtype == GLL)
                @test nmeas.last_GLL.valid
            elseif (mtype == ZDA)
                @test nmeas.last_ZDA.valid
            elseif (mtype == DTM)
                @test nmeas.last_DTM.valid
            else
                continue
            end
        end
    end
end

@testset "Test with Data File: `update` & `NMEAParser.pop!`" begin
    nmeas = NMEAData()
    open("$(@__DIR__())/testdata.txt", "r") do f
        while !eof(f)
            line = readline(f)
            if !NMEAParser.is_string_supported(line)
                @test_throws ArgumentError NMEAParser.nmea_parse(line)
                continue
            end
            nmea_data = NMEAParser.nmea_parse(line)
            nmeas = NMEAParser.update(nmea_data, nmeas)
            mtype = typeof(nmea_data)
            if (mtype == GGA)
                @test !isnothing(nmeas.last_GGA)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GGA)
            elseif (mtype == RMC)
                @test !isnothing(nmeas.last_RMC)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_RMC)
            elseif (mtype == GSA)
                @test !isnothing(nmeas.last_GSA)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GSA)
            elseif (mtype == GSV)
                @test !isnothing(nmeas.last_GSV)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GSV)
            elseif (mtype == GST)
                @test !isnothing(nmeas.last_GST)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GST)
            elseif (mtype == GBS)
                @test !isnothing(nmeas.last_GBS)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GBS)
            elseif (mtype == VTG)
                @test !isnothing(nmeas.last_VTG)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_VTG)
            elseif (mtype == GLL)
                @test !isnothing(nmeas.last_GLL)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GLL)
            elseif (mtype == ZDA)
                @test !isnothing(nmeas.last_ZDA)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_ZDA)
            elseif (mtype == DTM)
                @test !isnothing(nmeas.last_DTM)
                @test nmea_data == NMEAParser.pop!(nmeas, mtype)
                @test isnothing(nmeas.last_DTM)
            else
                continue
            end
        end
    end
end

@testset verbose = true "Test GNSS data" begin
    @testset "RTK GPS" begin
        nmea_data_simple =
            raw"$GPGGA,181908.00,3404.7041778,N,07044.3966270,W,4,13,1.00,495.144,M,29.200,M,0.10,0000*5f"
        example = NMEAParser.nmea_parse(nmea_data_simple)
        @test(example.latitude ≈ 34.078402963)

        nmea_data_gp =
            raw"$GPGGA,154922.620,5209.731,N,00600.238,E,1,12,1.0,0.0,M,0.0,M,,*67"
        example = NMEAParser.nmea_parse(nmea_data_gp)
        @test(example.latitude ≈ 52.162183)
    end

    @testset "RTK COMBINED" begin
        nmea_data_gn =
            raw"$GNGGA,134904.00,5209.54171860,N,00642.97846966,E,4,21,0.9,23.8908,M,43.8503,M,01,4095*45"
        example = NMEAParser.nmea_parse(nmea_data_gn)
        @test(example.latitude ≈ 52.159028643)
    end

    @testset "Standard GPS" begin
        example = NMEAParser.nmea_parse(
            raw"$GPGGA,134740.000,5540.3248,N,01231.2992,E,1,09,0.9,20.2,M,41.5,M,,0000*61",
        )
        @test(example.latitude ≈ 55.67208)
    end

    @testset "Standard Combined" begin
        example = NMEAParser.nmea_parse(
            "\$GNGGA,033158.447,4532.5164,N,12258.1463,W,1,9,1.25,161.5,M,-19.6,M,,*7E",
        )
        @test(example.longitude ≈ -122.969105)
    end
end

@testset "Test (GSA) GNSS DOP and Active Satellites" begin
    example = NMEAParser.nmea_parse(
        raw"$GPGSA,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,1.0,1.0*30",
    )
    @test example.current_mode === 3
end

@testset "Test (RMC) Recommended Minimum Specific GNSS Data" begin
    example = NMEAParser.nmea_parse(
        raw"$GPRMC,154922.720,A,5209.731,N,00600.238,E,001.9,059.8,040123,000.0,W*7A",
    )
    @test example.sog == 1.9
end

@testset "Bad data: parse_msg!" begin
    s = NMEAData()
    @test_throws BoundsError NMEAParser.parse_msg!(s, "")
    @test NMEAParser.parse_msg!(
        s,
        raw"$NOTAREALHEADER,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,1.0,1.0*30",
    ) === Nothing
end

@testset "hash strings" begin
    msg = raw"$GPRMC,154922.720,A,5209.731,N,00600.238,E,001.9,059.8,040123,000.0,W"
    checksum = 0x7a
    @test NMEAParser.hash_msg(msg) === checksum

    @test NMEAParser._char_xor('s', '#') === NMEAParser._char_xor('#', 's')
    @test NMEAParser._char_xor('s', 0x23) === NMEAParser._char_xor(0x23, 's')
    @test NMEAParser._char_xor('s', '#') === NMEAParser._char_xor('s', 0x23)
end

@testset "supported nmea" begin
    line = raw"$GPGGA,134740.000,5540.3248,N,01231.2992,E,1,09,0.9,20.2,M,41.5,M,,0000*61"
    @test NMEAParser.is_string_proprietary(line) === false
    @test NMEAParser.is_string_supported(line)
end

@testset verbose = true "unit conversion" begin
    @testset "Degrees Minutes Seconds to Decimal Degrees" begin
        @test NMEAParser._dms_to_dd("4807.038", "N") == 48.1173

        @test_throws ArgumentError NMEAParser._dms_to_dd("", "N")
        @test_throws ArgumentError NMEAParser._dms_to_dd("4807038", "N")
    end

    @testset "Hour Minutes Seconds to Seconds" begin
        @test NMEAParser._hms_to_secs("123519") == 45319.0

        @test_throws ArgumentError NMEAParser._hms_to_secs("00")
    end

    @testset "Pos conversion" begin
        # Test conversion from feet to meters
        @test NMEAParser.pos_convert('F', 10.0) ≈ 3.048

        # Test conversion from miles to meteres
        @test NMEAParser.pos_convert('N', 3.12) ≈ 5021.15328

        # Test conversion from kilometers to meters
        @test NMEAParser.pos_convert('K', 5.0) === 5000.0

        # Test conversion from meters (no conversion needed)
        @test NMEAParser.pos_convert('M', 5000.0) === 5000.0

        # Test for unsupported unit
        @test_throws ArgumentError NMEAParser.pos_convert('_', 10.0)
    end

    @testset "Vel conversion" begin
        # Test conversion from knotts to mps
        @test NMEAParser.vel_convert('N', 19.4384449244) ≈ 10.0
        # Test conversion from kph to mps
        @test NMEAParser.vel_convert('K', 36.0) === 10.0
        # Test conversion from mps (no conversion needed)
        @test NMEAParser.vel_convert('M', 10.0) === 10.0
        # Test for unsupported unit
        @test_throws ArgumentError NMEAParser.vel_convert('X', 10.0)
    end

    @testset "Orientation conversion" begin
        @test 1.0 == NMEAParser.orientation_convert('R', 1.0)
    end
end

@testset verbose = true "Test Proprietary Relative Position and Orientation types" begin
    @testset "PASHR" begin
        @test NMEAParser.is_string_proprietary(
            raw"$PASHR,154155.50,153.17,T,9.68,2.29,-0.07,0.502,0.502,0.959,1,0*19",
        )
        example = NMEAParser.nmea_parse(
            raw"$PASHR,154155.50,153.17,T,9.68,2.29,-0.07,0.502,0.502,0.959,1,0*19",
        )
        @test example.heading == 153.17
        example = NMEAParser.nmea_parse(
            raw"$PASHR,154156.00,152.12,T,9.52,2.05,-0.06,0.504,0.504,0.956,1,0*12",
        )
        @test example.heading_type
        example = NMEAParser.nmea_parse(
            raw"$PASHR,154156.10,151.86,T,9.46,1.98,-0.06,0.507,0.507,0.955,1,0*1C",
        )
        @test example.ins_code == 0
    end
    @testset verbose = true "WPS based Position" begin
        @testset "PTWPOS" begin
            @test NMEAParser.is_string_proprietary(
                raw"$PTWPOS,154922.69,0.7,M,0.7,M,0,M,0.989949,M,0.01,K,F*07",
            )
            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,154922.69,0.7,M,0.7,M,0,M,0.989949,M,0.01,K,F*07",
            )
            @test example.valid
            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,154922.7,0.8,M,0.8,M,0,M,1.131371,M,0.01,K,F*34",
            )
            @test example.valid

            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,021539.44,00000001.770,M,00000000.870,M,0000.000,M,0007.620,M,000.011281,K,F*88",
                validate_checksum = false,
            )
            @test example.xpose === 1.77
            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,021539.63,00000001.772,M,00000000.870,M,0000.000,M,0007.623,M,000.045134,K,F*fe",
                validate_checksum = false,
            )
            @test example.ypose === 0.87
            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,021539.72,00000001.774,M,00000000.870,M,0000.000,M,0007.624,M,000.067707,K,F*17",
                validate_checksum = false,
            )
            @test example.direction === 'F'
            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,021539.82,00000001.775,M,00000000.870,M,0000.000,M,0007.626,M,000.045134,K,F*dd",
                validate_checksum = false,
            )
            @test example.time === 8139.82
            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,021539.91,00000001.776,M,00000000.870,M,0000.000,M,0007.627,M,000.045134,K,F*60",
                validate_checksum = false,
            )
            @test example.distance === 7.627
            example = NMEAParser.nmea_parse(
                raw"$PTWPOS,021540.01,00000001.778,M,00000000.871,M,0000.000,M,0007.628,M,000.045134,K,F*e9",
                validate_checksum = false,
            )
            @test example.velocity ≈ 0.012537222222222222

            bad_pos = "\$TWPOS,154922.71,0.9,H,0.9,J,0,K,1.272792,M,0.01,M,F*39"
            @test_throws ArgumentError NMEAParser.nmea_parse(
                bad_pos,
                validate_checksum = false,
            )
            bad_vel = "\$TWPOS,154922.72,1.0,K,1.0,K,0,K,1.414214,K,0.01,Q,F*3a"
            @test_throws ArgumentError NMEAParser.nmea_parse(
                bad_vel,
                validate_checksum = false,
            )
        end
        @testset "PTWVCT" begin
            @test NMEAParser.is_string_proprietary(
                raw"$PTWVCT,154932.45,0.7,M,0.7,R,0.4,M,0.989949,MPS*3d",
            )
            example = NMEAParser.nmea_parse(
                raw"$PTWVCT,154932.45,0.7,M,0.7,R,0.4,M,0.989949,MPS*3d",
            )
            @test example.valid
        end
        @testset "PTWPLS" begin
            @test NMEAParser.is_string_proprietary(raw"$PTWPLS,021540.19,12,P,14,P,20,D*54")
            example = NMEAParser.nmea_parse(raw"$PTWPLS,021540.19,12,P,14,P,20,D*54")
            @test example.valid
        end
        @testset "PTWWHE" begin
            @test NMEAParser.is_string_proprietary(
                raw"$PTWWHE,021539.62,12,0.3,M,F,12,0.3,M,F,0.01*30",
            )
            example =
                NMEAParser.nmea_parse(raw"$PTWWHE,021539.62,12,0.3,M,F,12,0.3,M,F,0.01*30")
            @test example.valid
        end
    end

    @testset verbose = true "IMU based orientation" begin
        @testset "TWHPR" begin
            @test NMEAParser.is_string_proprietary(
                raw"$PTWHPR,161540.45,12.456,78.901,2.34,79.912,0.12*2E",
            )
            example = NMEAParser.nmea_parse(
                raw"$PTWHPR,161540.45,12.456,78.901,2.34,79.912,0.12*2E",
            )
            @test example.heading ≈ 12.456 atol = 1e-6
            @test example.pitch ≈ 78.901 atol = 1e-6
            @test example.roll ≈ 2.34 atol = 1e-6
            @test example.valid === true

            example_invalid = NMEAParser.nmea_parse(
                raw"$PTWHPR,161540.45,12.456,78.901,2.34,79.912,0.12*2C",
            )
            @test example_invalid.valid === false

            example_default = NMEAParser.nmea_parse(
                raw"$PTWHPR,161540.45,12.456,78.901,2.34,79.912,0.12*2C",
                validate_checksum = false,
            )
            @test example_default.system === "PROPRIETARY"
            @test example_default.valid === true
        end
        @testset "PTACC" begin
            @test NMEAParser.is_string_proprietary(
                raw"$PTACC,154156.65,0.777,0.123,0.011*43",
            )
            example = NMEAParser.nmea_parse(raw"$PTACC,154156.65,0.777,0.123,0.011*43")
            @test example.valid
        end
        @testset "PTGYR" begin
            @test NMEAParser.is_string_proprietary(
                raw"$PTGYR,156921.39,0.777,0.123,0.011*4d",
            )
            example = NMEAParser.nmea_parse(raw"$PTGYR,156921.39,0.777,0.123,0.011*4d")
            @test example.valid
        end
    end
end
