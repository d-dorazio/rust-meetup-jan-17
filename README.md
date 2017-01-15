# Rust meetup: January, 17

The main idea to focus the effort of this meetup is to produce a proxy application that translates a JSON protocol into a line based, telnet-style protocol.

The telnet server accepts only one connection and it can process only one command at the time. The proxy application, instead, should accept any number of clients and it should multiplex them to the telnet service.

## Telnet service

To keep things simple, this service simply reverses the case of the string in input. Maybe add a random delay of 500-1000ms between read and write to simulate some background processing.
Preferred language: Python, no compilation or toolchain involved. The quick and dirty version should be doable in 20 lines or so.

Example:
```
  input: command arg1 arg2
  output: COMMAND ARG1 ARG2
```

## JSON client

This is very simple as well, it just generates a JSON with a given format and it sends it to the proxy. It should run forever until terminated, so that we can run two instances and see that requests are multiplexed correctly by the proxy.
Preferred language: Python, so that no compilation is required.

Example:
```json
{
   "command": "some_command",
   "args": [ "arg1", "arg2"]
}
```
Probably we should randomize the strings inside "command" and "args" between successive requests.

## TODO
- [x] Telnet service
- [ ] JSON client
