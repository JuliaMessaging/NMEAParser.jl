# NMEAParser.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://NickMcSweeney.github.io/NMEAParser.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://NickMcSweeney.github.io/NMEAParser.jl/dev/)
[![Build Status](https://github.com/NickMcSweeney/NMEAParser.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/NickMcSweeney/NMEAParser.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/NickMcSweeney/NMEAParser.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/NickMcSweeney/NMEAParser.jl)
[![Coverage](https://coveralls.io/repos/github/NickMcSweeney/NMEAParser.jl/badge.svg?branch=main)](https://coveralls.io/github/NickMcSweeney/NMEAParser.jl?branch=main)

## Introduction

NMEAParser.jl is a Julia package for parsing NMEA GPS protocol sentences.

> Note: This package has recently been adopted from the original author. If you have any thoughts about improving the design or would like to contribute, please let us know.

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

example = parse(raw"$GPGGA,134740.000,5540.3248,N,01231.2992,E,1,09,0.9,20.2,M,41.5,M,,0000*61")
println(example.latitude)
```

```
GGA("GPS", 49660.0, 55.67208, 12.521653333333333, "GPS (SPS)", 9, 0.9, 20.2, 41.5, 0.0, 0, true)
55.67208
```

## Documentation

### Types
* `NMEAData`: Stores data for the last parsed sentence of all NMEA message types.
* `GGA`: Global Positioning System Fix Data.
* `GSA`: GNSS DOP and Active Satellites.
* `ZDA`: Time and Date.
* `GBS`: RAIM GNSS Satellite Fault Detection.
* `GLL`: Geographic Position - Latitude/Longitude.
* `GSV`: GNSS Satellites in View.
* `RMC`: Recommended Minimum Specific GNSS Data.
* `VTG`: Course over Ground and Ground Speed.
* `DTM`: Datum.
* `PASHR` (proprietary): Inertial altitude data - source.
* `TWPOS` (proprietary): 2D Position data.

### Methods
* `parse_msg!`: Parses an NMEA line/sentence and stores data in an NMEAData object; returns the message type.
* `parse`: extends Base.parse and parses nmea strings to nmea type structs.

## Sponsorship
![sponsor logo](https://www.volkerwessels.com/dynamics/modules/SFIL0200/view.php?fil_Id=366300&thumb_nr=26)

This package is developed and sponsored by [MapXact](https://mapxact.com/) and its development is driven by its use in production systems at MapXact. However, as an open-source project, we welcome all contributions, feedback, and feature requests.

## Contributing

If you would like to contribute to the project, please submit a PR.

This work is based on the [NMEA.jl](https://github.com/RobBlackwell/NMEA.jl) package, and a lot of credit is due to [RobBlackwell](https://github.com/RobBlackwell) for his work along with the other contributors to that repository.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
