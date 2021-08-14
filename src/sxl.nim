##
## SOURCE FILE: sxl.nim
##
## MIT License
## Copyright (c) 2021 Simon Rowe
##

# nim c -r -d:ssl .\sxl.nim

# import the required Nim standard library modules
import httpclient, json, strformat, strutils, options, times, os, terminal, threadpool

# import our own modules from this apps source code repo
import types, dbgUtils, version, help

proc returnWebSiteData*(webUrl: string): string =
  ##
  ## PROCEDURE: returnWebSiteData
  ## Input: URL for Space X Next Launch site to obtain web site data
  ## Returns: raw web page body received
  ## Description: open the provided URL returning the web site content received.
  ## On error a message is display and program quits.
  ##
  var client = newHttpClient()
  defer: client.close()
  let response = client.get(webUrl)
  result = response.body

  debug "web site response: " & response.status
  # output all received web site data with below if needed
  #debug "web data receivedL " & result

  if response.code != Http200:
    stderr.writeLine "\nFATAL ERROR: web site returned unexpected status of: ",
        response.status, "\n"
    stderr.writeLine "Data received:\n\n", result, "\n\n"
    quit 1

  if result.len == 0:
    stderr.writeLine "\nFATAL ERROR: no data received from web site"
    quit 2

proc returnParsedJson*(rawJsonData: string): JsonNode =
  ##
  ## PROCEDURE: returnParsedJson
  ## Input: raw web page body containing JSON data from SpaceX API web site
  ## Returns: populated JsonNode containing the launch data
  ## Description: read raw json data passed to the function and try to convert
  ## it into a JSON node object, that is return on success. If the conversion
  ## fails then raise an exception.
  ##
  debug "running: 'proc returnParsedJson'"

  try:
    result = parseJson(rawJsonData)
  except JsonParsingError:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "ERROR: Got JSON exception ", repr(e), " with message ", msg
  except:
    echo "Unknown exception error when parsing JSON!"


proc extractPayloadData*(jsonDataPayload: JsonNode):string =
  ##
  ## PROCEDURE: extractPayloadData
  ## Input: JsonNode containing payload data from the API site
  ## Returns: formatted string of payloads required fields
  ## Description: converts to JsonNode into the required fields
  ## as defined by the 'type Payload'. A formatted string is returned
  ## contain a single payload information set.

  # use the 'type Payload' as defined in 'types.nim' source code file.
  var pl = Payload()

  debug fmt"unmarshall 'jsonDataPayload' to object structure 'Payload'"
  #echo repr(jsonDataPayload)

  # unmarshall 'jsonDataPayload' to object structure 'Payload'
  try:
    pl = to(jsonDataPayload, Payload)
    #echo repr(nl)
  except:
    let e = getCurrentException()
    let msg = getCurrentExceptionMsg()
    echo fmt"ERROR: Got JSON unmarshall exception: '{repr(e)}' with message: {msg}"
    discard

  # get values needed from pl JSON data:
  debug fmt"JSON unmarshall process completed"

  # below outputs all data or 'nil' if unmarshall above fails...
  # ensure unmarshall worked and data was extracted ok... otherwise quit()
  if isNil pl:
    echo "FATAL ERROR: unmarshall of JSON 'jsonDataPayload' provided no data"
    quit 3

  debug "Raw extracted JSON data: " & repr(pl)

  # list of payload customers
  var customers:string
  # extract any customers if available
  if pl.customers.len > 0:
    for customerItem in pl.customers:
      customers.add fmt" '{customerItem}'"
  else:
      customers = "'UNKNOWN'"

  # list of payload manufacturers
  var manufacturers:string
  # extract any manufacturers if available
  if pl.manufacturers.len > 0:
    for manufacturersItem in pl.manufacturers:
      manufacturers.add fmt" '{manufacturersItem}'"
  else:
      manufacturers = "'UNKNOWN'"

  result = fmt"Payload is: {pl.name} ({pl.`type`}) for customer(s): {strip(customers)}. Payload manufactured by: {strip(manufacturers)}"


proc getPayloadData(payLoads:seq[string]):string =
  ##
  ## PROCEDURE: getPayloadData
  ## Input: sequence of payload ids
  ## Returns: formatted string of payloads included for launch
  ## Description: if the payloads sequence 'payLoads' has any
  ## entries, each of the payload ids is obtained from the 
  ## web site. Each ids payload information is appended to a
  ## string 'combinedPayload' which is returned by the proc

  debug "Payload sequence for processing: " & repr(payLoads)

  var combinedPayload:string

  if payLoads.len > 0:
    for item in payLoads:
      let payLoadUrl = fmt"https://api.spacexdata.com/v4/payloads/{item}"
      debug "Final payload URL: " & payLoadUrl
      let rawPayloadData = returnWebSiteData(payLoadUrl)
      let jsonDataPayload = returnParsedJson(rawPayloadData)
      combinedPayload.add extractPayloadData(jsonDataPayload)

  debug "Completed data from payload extraction: " & combinedPayload
  result = combinedPayload

proc extractLaunchPadData*(jsonDataLaunchPad: JsonNode):string =
  ##
  ## PROCEDURE: extractLaunchPadData
  ## Input: JsonNode containing launchpad data from the API site
  ## Returns: formatted string of launchpads required fields
  ## Description: converts to JsonNode into the required fields
  ## as defined by the 'type LaunchPad'. A formatted string is returned
  ## contain a single launchpad information set.

  # use the 'type LaunchPad' as defined in 'types.nim' source code file.
  var lp = LaunchPad()

  debug fmt"unmarshall 'jsonDataLaunchPad' to object structure 'LaunchPad'"
  #echo repr(jsonDataLaunchPad)

  # unmarshall 'jsonDataLaunchPad' to object structure 'LaunchPad'
  try:
    lp = to(jsonDataLaunchPad, LaunchPad)
    #echo repr(nl)
  except:
    let e = getCurrentException()
    let msg = getCurrentExceptionMsg()
    echo fmt"ERROR: Got JSON unmarshall exception: '{repr(e)}' with message: {msg}"
    discard

  # get values needed from lp JSON data:
  debug fmt"JSON unmarshall process completed"

  # below outputs all data or 'nil' if unmarshall above fails...
  # ensure unmarshall worked and data was extracted ok... otherwise quit()
  if isNil lp:
    echo "FATAL ERROR: unmarshall of JSON 'jsonDataLaunchPad' provided no data"
    quit 3

  debug "Raw extracted JSON data: " & repr(lp)

  result = fmt"{lp.full_name} ({lp.region}).  Launched {lp.launch_successes} of {lp.launch_attempts} attempts."

proc getLaunchPadData(LaunchPadId:string):string =
  ##
  ## PROCEDURE: getLaunchPadData
  ## Input: the ID of the launchpad
  ## Returns: formatted string of launchpad information
  ## Description: if the payloads sequence 'payLoads' has any
  ## entries, each of the payload ids is obtained from the 
  ## web site. Each ids payload information is appended to a
  ## string 'combinedPayload' which is returned by the proc

  debug "LaunchPad ID for processing: " & repr(LaunchPadId)

  var launchPadData:string

  if LaunchPadId.len > 0:
    let launchPadUrl = fmt"https://api.spacexdata.com/v4/launchpads/{LaunchPadId}"
    debug "Final payload URL: " & launchPadUrl
    let rawLaunchPadData = returnWebSiteData(launchPadUrl)
    let jsonDataLaunchPad = returnParsedJson(rawLaunchPadData)
    launchPadData.add extractLaunchPadData(jsonDataLaunchPad)

  debug "Completed data from launchPad extraction: " & launchPadData
  result = launchPadData

proc extractNextLaunch*(jsonDataNextLaunch: JsonNode):string =
  ##
  ## PROCEDURE: extractNextLaunch
  ## Input: Next Launch object, JsonNode (from SpaceX API site)
  ## Returns: formatted string of next launch data for output
  ## Description: use the NextLaunch JSON object to extract all the
  ## NextLaunch content needed into the structure 'NextLaunch'.
  ## The unmarshalled data is then placed in the 'nl' object.

  # Structure to hold unmarshalled data created using 'nimjson' tool.
  # see 'types.nim' for structure
  var nl = NextLaunch()
  
  debug fmt"unmarshall 'jsonDataNextLaunch' to object structure 'NextLaunch'"
  #echo repr(jsonDataNextLaunch)

  # unmarshall 'jsonDataNextLaunch' to object structure 'NextLaunch'
  try:
    nl = to(jsonDataNextLaunch, NextLaunch)
    #echo repr(nl)
  except:
    let e = getCurrentException()
    let msg = getCurrentExceptionMsg()
    echo fmt"ERROR: Got JSON unmarshall exception: '{repr(e)}' with message: {msg}"
    discard

  # get values needed from nl JSON data:
  debug fmt"JSON unmarshall process completed"

  # below outputs all data or 'nil' if unmarshall above fails...
  # ensure unmarshall worked and data was extracted ok... otherwise quit()
  if isNil nl:
    echo "FATAL ERROR: unmarshall of JSON 'jsonDataNextLaunch' provided no data"
    quit 3

  debug "Extracted JSON data: " & repr(nl)

  if nl.details.len == 0:
    nl.details = "None available."

  # obtain any details for the rocket launchpad
  debug "LaunchPad data is: " & nl.launchpad
  let launchPadInfo = getLaunchPadData(nl.launchpad)

  # obtain any details for the included rocket payload
  debug "Payload data is: " & nl.payloads
  let allPayloads = getPayloadData(nl.payloads)

  #let sdate: string = $fromUnix(nl.date_unix).format("ddd dd MMM yyyy HH:mm:ss")
  #debug fmt"sdate is: {sdate}"
  #let edate: string = $fromUnix(item.expires).format("ddd dd MMM yyyy HH:mm:ss")
  #var regionAll: string
  # regions is containedin a seq - so obtian all
  # for regionitem in item.regions:
  #   regionAll.add fmt" {regionitem}"

  # convert any extracted dates to required output format
  let estLaunchDate:string = $fromUnix(nl.date_unix).format("ddd dd MMM yyyy HH:mm:ss")

  result = fmt"""

Next Scheduled SpaceX Launch 🚀

Flight Number    : {nl.flight_number}
Flight Name      : {nl.name}
Launchpad        : {launchPadInfo}
Est. Launch Date : {estLaunchDate} [Precision: {toUpperAscii(nl.date_precision)}]

Payload Description: 
{allPayloads}

Flight Description: 
{nl.details}"""

proc extractLatestLaunch*(jsonDataLatestLaunch: JsonNode):string =
  ##
  ## PROCEDURE: extractLatestLaunch
  ## Input: Latest Launch object, JsonNode (from SpaceX API site)
  ## Returns: formatted string of Latest launch data for output
  ## Description: use the LatestLaunch JSON object to extract all the
  ## LatestLaunch content needed into the structure 'LatestLaunch'.
  ## The unmarshalled data is then placed in the 'nl' object.

  # Structure to hold unmarshalled data created using 'nimjson' tool.
  # see 'types.nim' for structure
  var ll = LatestLaunch()
  
  debug fmt"unmarshall 'jsonDataLatestLaunch' to object structure 'LatestLaunch'"
  #echo repr(jsonDataLatestLaunch)

  # unmarshall 'jsonDataLatestLaunch' to object structure 'LatestLaunch'
  try:
    ll = to(jsonDataLatestLaunch, LatestLaunch)
    #echo repr(ll)
  except:
    let e = getCurrentException()
    let msg = getCurrentExceptionMsg()
    echo fmt"ERROR: Got JSON unmarshall exception: '{repr(e)}' with message: {msg}"
    discard

  # get values needed from ll forecast JSON data:
  debug fmt"JSON unmarshall process completed"

  # below outputs all data or 'nil' if unmarshall above fails...
  # ensure unmarshall worked and data was extracted ok... otherwise quit()
  if isNil ll:
    echo "FATAL ERROR: unmarshall of JSON 'jsonDataLatestLaunch' provided no data"
    quit 3

  debug "Extract JSON data: " & repr(ll)

  #let sdate: string = $fromUnix(ll.date_unix).format("ddd dd MMM yyyy HH:mm:ss")
  #debug fmt"sdate is: {sdate}"
  #let edate: string = $fromUnix(item.expires).format("ddd dd MMM yyyy HH:mm:ss")
  #var regionAll: string
  # regions is containedin a seq - so obtian all
  # for regionitem in item.regions:
  #   regionAll.add fmt" {regionitem}"

  # get the launch status which should be a bool if set
  var launchStatus: string
  if ll.success.isSome():
    debug fmt"Launch status 'success' data available... extracting"
    let successData = ll.success.get()
    launchStatus = if successData : "successful" else: "failed"

  # obtain any details for the rocket launchpad
  debug "LaunchPad data is: " & ll.launchpad
  let launchPadInfo = getLaunchPadData(ll.launchpad)

  # obtain any details for the included rocket payload
  debug "Payload data is: " & ll.payloads
  let allPayloads = getPayloadData(ll.payloads)

  # convert any extracted dates to required output format
  let actualLaunchDate:string = $fromUnix(ll.date_unix).format("ddd dd MMM yyyy HH:mm:ss")

  result = fmt"""

Last SpaceX Launch 🚀

Flight Number : {ll.flight_number}
Flight Name   : {ll.name}
Launchpad     : {launchPadInfo}
Launch Date   : {actualLaunchDate}
Launch Status : {launchStatus}

Payload Description: 
{allPayloads}

Flight Description: 
{ll.details}"""


proc progressUpdate(message:string) =
  eraseLine(stdout)
  write(stdout, message)
  flushFile(stdout)

proc lastLaunchCollate() : string =
  progressUpdate "Last Launch: Obtaining latest launch data..."
  let LatestLaunchUrl = r"https://api.spacexdata.com/v4/launches/latest"
  progressUpdate "Last Launch: Extracting JSON from web site response..."
  let rawLatesLaunchData = returnWebSiteData(LatestLaunchUrl)
  progressUpdate "Last Launch: Parsing JSON to obtain data required..."
  let jsonDataLatestLaunch = returnParsedJson(rawLatesLaunchData)
  progressUpdate "Last Launch: Formatting information for display..."
  let LatestLaunchOutput = extractLatestLaunch(jsonDataLatestLaunch)
  progressUpdate "Last Launch: Completed latest launch data retrieval."
  result = LatestLaunchOutput

proc nextLaunchCollate(): string =
  progressUpdate "Next Launch: Obtaining next launch data..."
  let NextLaunchUrl = r"https://api.spacexdata.com/v4/launches/next"
  progressUpdate "Next Launch: Extracting JSON from web site response..."
  let rawNextLaunchData = returnWebSiteData(NextLaunchUrl)
  progressUpdate "Next Launch: Parsing JSON to obtain data required..."
  let jsonDataNextLaunch = returnParsedJson(rawNextLaunchData)
  progressUpdate "Next Launch: Formatting information for display..."
  let NextLaunchOutput = extractNextLaunch(jsonDataNextLaunch)
  progressUpdate "Next Launch: Completed next launch data retrieval."
  result = NextLaunchOutput

###############################################################################
# MAIN HERE
###############################################################################

# check for command line options use
let args = commandLineParams()
if paramCount() > 0:
  case args[0]
  of "-h", "--help":
    showHelp()
  of "-v", "--version":
    showVersion()
  else:
    echo "Unknown command line parameter given - see options below:"
    showHelp()


let NextLaunchOutput = (^spawn nextLaunchCollate())
let LatestLaunchOutput = (^spawn lastLaunchCollate())
#sync()

eraseLine(stdout)
flushFile(stdout)

echo "\nSpaceX Rocket Launch Information"
echo "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
echo LatestLaunchOutput
echo NextLaunchOutput
echo ""
