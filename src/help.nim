##
## SOURCE FILE: help.nim
## 
## MIT License
## Copyright (c) 2021 Simon Rowe
## https://github.com/wiremoons/
##


# import the required Nim standard library modules
import strformat, os

proc showHelp*() =
  ##
  ## PROCEDURE: showHelp
  ## Input: none required
  ## Returns: outputs help information to the display then quits the program
  ## Description: display command line help information requested by the user
  ##
  let appName = extractFilename(getAppFilename())
  echo fmt"""
Purpose
¯¯¯¯¯¯¯
 Use the '{appName}' application to find the last launch and the next 
 scheduled launch of SpaceX rockets.

Usage
¯¯¯¯¯
Run ./{appName} with:

    Flag      Description                          Default Value
    ¯¯¯¯      ¯¯¯¯¯¯¯¯¯¯¯                          ¯¯¯¯¯¯¯¯¯¯¯¯¯
    -h        display help information             false
    -v        display program version              false
"""
  quit 0


# Allow module to be run standalone for tests
when isMainModule:
  showHelp()
