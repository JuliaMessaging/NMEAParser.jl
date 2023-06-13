module PrecompileExt # Should be same name as the file (just like a normal package)

using PrecompileTools, NMEAParser

@setup_workload begin
    @debug "running optional precompiler set"
    test_msgs = [
        raw"$GPGGA,134735.000,5540.3232,N,01231.2946,E,1,10,0.8,23.6,M,41.5,M,,0000*69",
        raw"$GPGSA,A,3,03,22,06,19,11,14,32,01,28,18,,,1.8,0.8,1.6*3F",
        raw"$GPRMC,134735.000,A,5540.3232,N,01231.2946,E,1.97,88.98,041112,,,A*5C",
        raw"$GPVTG,88.98,T,,M,1.97,N,3.6,K,A*36",
        raw"$GLGSV,3,3,09,72,07,273,,0*44",
        raw"$GNRMC,094810.000,A,5547.94084,N,03730.27293,E,0.25,50.34,260420,,,A,V*31",
        raw"$GNVTG,50.34,T,,M,0.25,N,0.46,K,A*14",
        raw"$GNZDA,094810.000,26,04,2020,00,00*4C",
        raw"$GNGLL,5547.94084,N,03730.27293,E,094810.000,A,A*4B",
    ]
    @compile_workload begin
        nmea_strings = NMEAParser.nmea_parse.(test_msgs)
    end
end

end # PrecompileTools Extension
