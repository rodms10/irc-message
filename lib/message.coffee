###
  irc-message
  Copyright (c) 2013 Fionn Kelleher. All rights reserved.
  Licensed under the BSD 2-Clause License (FreeBSD) - see LICENSE.md.
###

class Message
  constructor: (line) ->
    @tags = {}
    @prefix = ""
    @command = ""
    @args = []
    position = 0
    nextspace = 0

    if line.charAt(0) is "@"
      nextspace = line.indexOf " "
      throw new Error "Expected prefix; malformed IRC message." if nextspace is -1
      rawTags = line.slice(1, nextspace).split ";"

      for tag in rawTags
        pair = tag.split "="
        @tags[pair[0]] = pair[1] or yes

      position = nextspace + 1

    position++ while line.charAt(position) is " "

    if line.charAt(position) is ":"
      nextspace = line.indexOf " ", position
      throw new Error "Expected command; malformed IRC message." if nextspace is -1
      @prefix = line.slice position + 1, nextspace
      position = nextspace + 1
      position++ while line.charAt(position) is " "

    nextspace = line.indexOf " ", position

    if nextspace is -1
      if line.length > position
        @command = line.slice(position)
      else return

    @command = line.slice(position, nextspace)

    position = nextspace + 1
    position++ while line.charAt(position) is " "

    while position < line.length
      nextspace = line.indexOf " ", position
      if line.charAt(position) is ":"
        @args.push line.slice position + 1
        break

      if nextspace isnt -1
        @args.push line.slice position, nextspace
        position = nextspace + 1
        position++ while line.charAt(position) is " "
        continue

      if nextspace is -1
        @args.push line.slice position
        break
    return

  toString: ->
    string = ""
    if Object.keys(@tags).length isnt 0
      string += "@"
      for tag, value of @tags
        if value isnt null
          string += "#{tag}=#{value};"
        else string += "#{tag};"
      string = string.slice(0, -1) + " "

    if @prefix.length isnt 0
      string += ":#{@prefix} "

    if @command.length isnt 0
      string += "#{@command} "

    if @args.length isnt 0
      for arg in @args
        if arg.indexOf " " isnt -1
          string += "#{arg} "
        else
          string += ":#{arg} "

    string = string.slice 0, -1
    return string

  prefixIsUserHostmask: -> (@prefix.indexOf("@") isnt -1 and @prefix.indexOf("!") isnt -1)
  prefixIsServerHostname: -> (@prefix.indexOf("@") is -1 and @prefix.indexOf("!") is -1 and @prefix.indexOf(".") isnt -1)
  parseHostmask: ->
    [nickname, username, hostname] = @prefix.split /[!@]/
    parsed =
      nickname: nickname
      username: username
      hostname: hostname
    parsed

exports = module.exports = Message