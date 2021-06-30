import options

type
  NextLaunch* = ref object
    flight_number*: int
    name*: string
    details*: string
    date_unix*: int64
    date_precision*: string
    payloads*: seq[string]
    launchpad*: string

type
  LatestLaunch* = ref object
    flight_number*: int
    name*: string
    details*: string
    date_unix*: int64
    payloads*: seq[string]
    launchpad*: string
    success*: Option[bool]

type
  Payload* = ref object
    name*: string
    `type`*: string
    customers*: seq[string]
    manufacturers*: seq[string]

type
  LaunchPad* = ref object
    full_name*: string
    region*: string
    launch_attempts*: int
    launch_successes*: int