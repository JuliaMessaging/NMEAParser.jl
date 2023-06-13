using Test, Aqua, NMEAParser

Aqua.test_ambiguities([NMEAParser, Base, Core])
Aqua.test_unbound_args(NMEAParser)
Aqua.test_undefined_exports(NMEAParser)
Aqua.test_project_extras(NMEAParser)
Aqua.test_stale_deps(NMEAParser; ignore=[:Aqua])
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
end
