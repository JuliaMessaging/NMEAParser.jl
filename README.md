# NMEAParser.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaMessaging.github.io/NMEAParser.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaMessaging.github.io/NMEAParser.jl/dev/)
[![Build Status](https://github.com/JuliaMessaging/NMEAParser.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaMessaging/NMEAParser.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaMessaging/NMEAParser.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaMessaging/NMEAParser.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## NOTICE: THIS PACKAGE IS NO LONGER UNDER ACTIVE MAINTENANCE. 

Hopefully there is no need for maintenance, because this is a relatively simple package, and should be able to be used as is. However as Julia is a rapidly changing language I expect there to eventually be compatibility issues. I am working on a NMEAProtocol.jl package that can read and write NMEA strings from Julia and plan for this package to be a replacement for NMEAParser.jl. Ideally it will be ready to go by the time this packages starts breaking, but I have limited time to invest on this. 

FYI: I am making a new package because I want to align better with Julia code design and provide more functionality with better performance. This was not possible without a serious re-write of the package resulting in breaking changes that go beyond what can be contained in a simple release/update. I will update this message when the new package is functional.

## Introduction

NMEAParser.jl is a Julia package for parsing NMEA GPS protocol sentences.

NMEA strings are sentences that follow the NMEA 0183 messaging protocol. The NMEA 0183 messaging protocol was originally adopted in 1983 for interfacing marine electronics, but its use has expanded to terrestrial electronics as well.

Data in this messaging protocol is transmitted in ASCII strings or “sentences” from one “talker” to multiple “listeners” at a time. These sentences contain information such as position, speed, depth, wind direction and speed, and other navigation data. NMEA strings are commonly used by GPS receivers and other navigation equipment to communicate with each other and with other devices such as computers and chart plotters.

## Getting Started

### Installation

To install NMEAParser.jl, use the Julia package manager:

```julia
using Pkg
Pkg.add("NMEAParser")
```

### Usage
Here’s a simple example that demonstrates how to parse an NMEA sentence:

```julia
using NMEAParser

example = nmea_parse(raw"$GPGGA,134740.000,5540.3248,N,01231.2992,E,1,09,0.9,20.2,M,41.5,M,,0000*61")
println(example.latitude)
```

```
GGA("GPS", 49660.0, 55.67208, 12.521653333333333, "GPS (SPS)", 9, 0.9, 20.2, 41.5, 0.0, 0, true)
55.67208
```

## Documentation

### Standard Types
* `GGA`: Global Positioning System Fix Data.
* `GSA`: GNSS DOP and Active Satellites.
* `ZDA`: Time and Date.
* `GBS`: RAIM GNSS Satellite Fault Detection.
* `GLL`: Geographic Position - Latitude/Longitude.
* `GSV`: GNSS Satellites in View.
* `RMC`: Recommended Minimum Specific GNSS Data.
* `VTG`: Course over Ground and Ground Speed.
* `DTM`: Datum.

#### Store obj for standard types
* `NMEAData`: Stores data for the last parsed sentence of all NMEA message types.

### Methods
* `parse_msg!`: Parses an NMEA line/sentence and stores data in an NMEAData object; returns the message type.
* `nmea_parse`: Parses nmea strings to nmea type structs.
* `is_string_supported`: Checks if a string is a valid standard type.
* `update`: Update the last received message of type T in the NMEAData object s with the given message msg.

## Contributing

If you would like to contribute to the project, please submit a PR. Or better, check out [NMEAProtocol.jl](https://github.com/NickMcSweeney/NMEAProtocol.jl) to contribute on the new and improved version of this package.

This work is based on the [NMEA.jl](https://github.com/RobBlackwell/NMEA.jl) package, and a lot of credit is due to [RobBlackwell](https://github.com/RobBlackwell) for his work along with the other contributors to that repository.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
