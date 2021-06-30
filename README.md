[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hyperium/hyper/master/LICENSE) [![sxl](https://github.com/wiremoons/spacex-launches/actions/workflows/sxl-build-nim.yml/badge.svg?branch=main)](https://github.com/wiremoons/spacex-launches/actions/workflows/sxl-build-nim.yml)

# spacex-launches (sxl)
Command line program called `sxl` to display the last and the next SpaceX launches.

## Application Usage

Under development - but working correctly so far...

Output of the program when run is:

```console
SpaceX Rocket Launch Information
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Last SpaceX Launch 🚀

Flight Number : 131
Flight Name   : GPS III SV05
Launchpad     : Cape Canaveral Space Force Station Space Launch Complex 40 (Florida).  Launched 72 of 74 attempts.
Launch Date   : Thu 17 Jun 2021 17:09:00
Launch Status : successful

Payload Description: 
Payload is: GPS III SV05 (Satellite) for customer(s): 'USAF'. Payload manufactured by: 'Lockheed Martin'

Flight Description: 
SpaceX's fourth GPS III launch will use the first stage from the previous GPS mission. This will be the first 
time a National Security Space Launch has flown on a flight proven booster. Falcon 9 will launch from SLC-40, 
Cape Canaveral and the booster will land downrange on a drone ship. GPS III is the third generation of the U.S.
Space Force's NAVSTAR Global Positioning System satellites, developed by Lockheed Martin. The GPS III constellation
will feature a cross-linked command and control architecture, allowing the entire GPS constellation to be updated
simultaneously from a single ground station. A new spot beam capability for enhanced military coverage and increased
resistance to hostile jamming will be incorporated.

Next Scheduled SpaceX Launch 🚀

Flight Number    : 132
Flight Name      : Transporter-2
Launchpad        : Cape Canaveral Space Force Station Space Launch Complex 40 (Florida).  Launched 72 of 74 attempts.
Est. Launch Date : Wed 30 Jun 2021 19:56:00 [Precision: HOUR]

Payload Description: 
Payload is: Transporter-2 (Satellite) for customer(s): 'UNKNOWN'. Payload manufactured by: 'UNKNOWN'

Flight Description: 
Falcon 9 launches to sun-synchronous polar orbit from Florida as part of SpaceX's Rideshare program dedicated to
smallsat customers. The mission lifts off from SLC-40, Cape Canaveral on a southward azimuth and performs a dogleg
maneuver. The booster for this mission is expected to return to LZ-1 based on FCC communications filings. This
rideshare takes approximately 90 satellites and hosted payloads into orbit on a variety of deployers including three
free-flying spacecraft which dispense their customers' satellites after separation from the SpaceX stack.
```

## Development Information

The application in written using the Nim programming language, so can be used on any supported operating systems such as Windows, Linux, FreeBSD, etc. More information about Nim is available here:

 - [Nim's web site](https://nim-lang.org/)
 - [Nim on GitHub](https://github.com/nim-lang/Nim)

## Building and Installing from Source 

If you wish to build `sxl` application yourself, then the instructions below should help. These cover Windows and Linux specifically, but hopefully they will help for other platforms too.

### Linux

The instruction below are for Linux, and have been tested on Ubuntu 20.04.2 LTS (aarch64 and x64) and macOS 'Bug Sur' 11.4.

To build 'sxl' from source on a Linux based system, the following steps can be used:

1. Install the Nim compiler and a C compiler such as GCC or Clangs, plus the OpenSSL library. More information on installing Nim can be found here: [Nim Download](https://nim-lang.org/install.html).
2. Once Nim is installed and working on your system, you can clone this GitHub repo with the command: `git clone https://github.com/wiremoons/spacex-launches.git`
3. Then in the cloned code directory for `spacex-launches` use Nimble to build a release version with the command: `nimble release`.   Other Nimble build commands can be seen by running: `nimble tasks`.
4. The compiled binary named `sxl` can now be found in the `./bin` sub directory. Just copy it somewhere in you path, and it should work when run.

### Windows 10

The instruction below have been tested on Windows 10 only, but should perform the same on most older versions too.

The quickest way I have found to install Nim and then build the `sxl` program your self is following the steps:

1. Open a Powershell command line window
2. Install the packages manager [scoop](https://scoop.sh/) by running: `iwr -useb get.scoop.sh | iex`
3. Install the packages: Nim; OpenSSL; Git; and GCC: `scoop install nim openssl git gcc`
4. Clone the *sxl* projects to your computer: `git clone https://github.com/wiremoons/spacex-launches.git`
5. Change directory into the newly create source directory :  `cd spacex-launches`
6. Build the *sxl* application: `nimble relese`
7. The build binary file should be located in the `bin` sub directory - run it with: `.\bin\sxl.exe`

You should now copy the `sxl.exe` file to a directory in your PATH to make it easier to use. Before it will work,
the set up needs to be completed, as below:

## Installing a Binary Version

One of the key benefits of having an application developed in Nim is that the resulting application is compiled in to a single binary file. The Windows version also requires a OpenSSL library, that is used to secure the communications with the API web site.

If you have [Nimble](https://github.com/nim-lang/nimble) installed on your system, this program can be installed with the command:
```
nimble install https://github.com/wiremoons/spacex-launches
```

## Acknowledgments and Other Info

The application would not be possible without the use of the [SpaceX REST API](https://github.com/r-spacex/SpaceX-API). Thank you for making the API and the data it provides available for use!

If you are interested in reading about what I have been programming in Nim, then you can find several Nim related articles on my blog here: [www.wiremoons.com](http://www.wiremoons.com/).

## License

The `sxl` application is provided under the *MIT* open source license. A copy of the MIT license file is [here](./LICENSE).

The [SpaceX REST API](https://github.com/r-spacex/SpaceX-API) is provided under the *Apache License Version 2.0* open source license. A copy of the license file is [here](https://github.com/r-spacex/SpaceX-API/blob/master/LICENSE).
