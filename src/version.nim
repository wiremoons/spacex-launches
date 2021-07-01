##
## SOURCE FILE: version.nim
##
## MIT License
## Copyright (c) 2021 Simon Rowe
## https://github.com/wiremoons/
##

# import the required Nim standard library modules
import strformat, os, strutils

proc showVersion*() =
  ##
  ## PROCEDURE: showVersion
  ## Input: none required
  ## Returns: outputs version information for the application and quits program
  ## Description: display the app version, build kind, build date, compiler
  ## version, plus license information, and sources repos.
  ##
  const ver = when defined(release): "release" else: "debug"
  const buildV = fmt"Built as '{ver}' using Nim compiler version: '{NimVersion}'"
  const NimblePkgVersion {.strdefine.} = "Unknown"
  let appName = extractFilename(getAppFilename())
  let hostData = fmt"{capitalizeAscii(hostOS)} ({toUpperAscii(hostCPU)})"

  echo fmt"""

'{appName}' is version: '{NimblePkgVersion}' running on: '{hostData}'.
Compiled on: {CompileDate} @ {CompileTime} UTC.
Copyright (c) 2021 Simon Rowe.

{buildV}.

For licenses and further information visit:
   - SpaceX Launches application :  https://github.com/wiremoons/spacex-launches/
   - SpaceX REST API             :  https://github.com/r-spacex/SpaceX-API
   - Nim language & compiler     :  https://github.com/nim-lang/Nim/

All is well.
"""
  quit 0

# Allow module to be run standalone for tests
when isMainModule:
  showVersion()
