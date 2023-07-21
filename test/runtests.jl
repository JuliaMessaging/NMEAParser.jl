using Test, NMEAParser

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
            elseif (mtype == PASHR)
                @test nmeas.last_PASHR.valid   
            elseif (mtype == TWPOS)
                @test nmeas.last_TWPOS.valid 
            else
                continue
            end
        end
    end
end

@testset "Test with Data File: `update` & `pop!`" begin
    nmeas = NMEAData()
    open("testdata.txt", "r") do f
        while !eof(f)
            line = readline(f)
            if !NMEAParser.is_string_supported(line)
                @test_throws ArgumentError NMEAParser.parse(line)
                continue
            end
            nmea_data = NMEAParser.parse(line)
            nmeas = NMEAParser.update(nmeas, nmea_data)
            mtype = typeof(nmea_data)
            if (mtype == GGA)
                @test !isnothing(nmeas.last_GGA)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GGA)
            elseif (mtype == RMC)
                @test !isnothing(nmeas.last_RMC)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_RMC)
            elseif (mtype == GSA)
                @test !isnothing(nmeas.last_GSA)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GSA)
            elseif (mtype == GSV)
                @test !isnothing(nmeas.last_GSV)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GSV)
            elseif (mtype == GBS)
                @test !isnothing(nmeas.last_GBS)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GBS)
            elseif (mtype == VTG)
                @test !isnothing(nmeas.last_VTG)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_VTG)
            elseif (mtype == GLL)
                @test !isnothing(nmeas.last_GLL)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_GLL)
            elseif (mtype == ZDA)
                @test !isnothing(nmeas.last_ZDA)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_ZDA)
            elseif (mtype == DTM)
                @test !isnothing(nmeas.last_DTM)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_DTM)
            elseif (mtype == PASHR)
                @test !isnothing(nmeas.last_PASHR)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_PASHR)
            elseif (mtype == TWPOS)
                @test !isnothing(nmeas.last_TWPOS)
                @test nmea_data == pop!(nmeas, mtype)
                @test isnothing(nmeas.last_TWPOS)
            else
                continue
            end
        end
    end
end

@testset verbose = true "Test SPS data" begin
    @testset "RTK GPS" begin
        nmea_data_simple = raw"$GPGGA,181908.00,3404.7041778,N,07044.3966270,W,4,13,1.00,495.144,M,29.200,M,0.10,0000*5f"
        example = NMEAParser.parse(nmea_data_simple)
        @test(example.latitude ≈ 34.078402963)

        nmea_data_gp = raw"$GPGGA,154922.620,5209.731,N,00600.238,E,1,12,1.0,0.0,M,0.0,M,,*67"
        example = NMEAParser.parse(nmea_data_gp)
        @test(example.latitude ≈ 52.162183)
    end

    @testset "RTK COMBINED" begin
        nmea_data_gn = raw"$GNGGA,134904.00,5209.54171860,N,00642.97846966,E,4,21,0.9,23.8908,M,43.8503,M,01,4095*45"
        example = NMEAParser.parse(nmea_data_gn)
        @test(example.latitude ≈ 52.159028643)
    end

    @testset "Standard GPS" begin
        example = NMEAParser.parse(raw"$GPGGA,134740.000,5540.3248,N,01231.2992,E,1,09,0.9,20.2,M,41.5,M,,0000*61")
        @test(example.latitude ≈ 55.67208)
    end

    @testset "Standard Combined" begin
        example = NMEAParser.parse("\$GNGGA,033158.447,4532.5164,N,12258.1463,W,1,9,1.25,161.5,M,-19.6,M,,*7E")
        @test(example.longitude ≈ -122.969105)
    end
end

@testset "Test Position data" begin
    example = NMEAParser.parse(raw"$TWPOS,154922.69,0.7,M,0.7,M,0,M,0.989949,M,0.01,K*3d")
    @test example.xpose === 0.7
    example = NMEAParser.parse(raw"$TWPOS,154922.7,0.8,M,0.8,M,0,M,1.131371,M,0.01,K*e")
    @test example.distance === 1.131371
end

@testset "Test (GSA) GNSS DOP and Active Satellites" begin
    example = NMEAParser.parse(raw"$GPGSA,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,1.0,1.0*30")
    @test example.current_mode === 3
end

@testset "Test (RMC) Recommended Minimum Specific GNSS Data" begin
    example = NMEAParser.parse(raw"$GPRMC,154922.720,A,5209.731,N,00600.238,E,001.9,059.8,040123,000.0,W*7A")
    @test example.sog == 1.9
end

@testset "Bad data: parse_msg!" begin
    s = NMEAData()
    @test_throws BoundsError NMEAParser.parse_msg!(s,"")
    @test_throws BoundsError NMEAParser.parse_msg!(s,"GPGSA,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,1.0,1.0*30")
end

@testset "Bad data: TWPOS" begin
    bad_pos = "\$TWPOS,154922.71,0.9,H,0.9,J,0,K,1.272792,M,0.01,M*39"
    @test_throws ArgumentError NMEAParser.parse(bad_pos)
    bad_vel = "\$TWPOS,154922.72,1.0,K,1.0,K,0,K,1.414214,K,0.01,Q*3a"
    @test_throws ArgumentError NMEAParser.parse(bad_vel)
end
