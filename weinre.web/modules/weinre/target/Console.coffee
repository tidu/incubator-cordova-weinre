
#---------------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#---------------------------------------------------------------------------------

Weinre   = require('../common/Weinre')
Timeline = require('../target/Timeline')

UsingRemote = false

RemoteConsole   = null
OriginalConsole = null

MessageSource =
    HTML:  0
    WML:   1
    XML:   2
    JS:    3
    CSS:   4
    Other: 5

MessageType =
    Log:                 0
    Object:              1
    Trace:               2
    StartGroup:          3
    StartGroupCollapsed: 4
    EndGroup:            5
    Assert:              6
    UncaughtException:   7
    Result:              8

MessageLevel =
    Tip:     0
    Log:     1
    Warning: 2
    Error:   3
    Debug:   4

ConsoleQueue = []

#-------------------------------------------------------------------------------
module.exports = class Console

    #---------------------------------------------------------------------------
    Console::__defineGetter__("original", -> OriginalConsole)

    #---------------------------------------------------------------------------
    @useRemote: (value) ->
        return UsingRemote if arguments.length == 0

        oldValue = UsingRemote
        UsingRemote = not not value

        if UsingRemote
            tmp = ConsoleQueue[..]
            ConsoleQueue = []   
            (fn() for fn in tmp)

        oldValue

    #---------------------------------------------------------------------------
    _generic: (level, messageParts) ->
        message = messageParts[0].toString()
        parameters = []

        for messagePart in messageParts
            parameters.push Weinre.injectedScript.wrapObjectForConsole(messagePart, true)

        payload =
            source: MessageSource.JS
            type: MessageType.Log
            level: level
            message: message
            parameters: parameters

        Weinre.wi.ConsoleNotify.addConsoleMessage payload

    #---------------------------------------------------------------------------
    log: ->
        args = [].slice.call(arguments)
        if UsingRemote
            @_generic MessageLevel.Log, args
        else
            ConsoleQueue.push(() -> RemoteConsole._generic(MessageLevel.Log, args))

        OriginalConsole.log(args)
        
    #---------------------------------------------------------------------------
    debug: ->
        args = [].slice.call(arguments)
        if UsingRemote
            @_generic MessageLevel.Debug, args
        else
            ConsoleQueue.push(() -> RemoteConsole._generic(MessageLevel.Debug, args))

        OriginalConsole.debug(args)
        
    #---------------------------------------------------------------------------
    error: ->
        args = [].slice.call(arguments)
        if UsingRemote
            @_generic MessageLevel.Error, args
        else
            ConsoleQueue.push(() -> RemoteConsole._generic(MessageLevel.Error, args))

        OriginalConsole.error(args)
        

    #---------------------------------------------------------------------------
    info: ->
        args = [].slice.call(arguments)
        if UsingRemote
            @_generic MessageLevel.Log, args
        else
            ConsoleQueue.push(() -> RemoteConsole._generic(MessageLevel.Log, args))

        OriginalConsole.error(args)
        

    #---------------------------------------------------------------------------
    warn: ->
        args = [].slice.call(arguments)
        if UsingRemote
            @_generic MessageLevel.Warning, args
        else
            ConsoleQueue.push(() -> RemoteConsole._generic(MessageLevel.Warning, args))

        OriginalConsole.warn([].slice.call(arguments))

    #---------------------------------------------------------------------------
    dir: ->
        OriginalConsole.dir([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    dirxml: ->
        OriginalConsole.dirxml([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    trace: ->
        OriginalConsole.trace([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    assert: (condition) ->
        OriginalConsole.assert([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    count: ->
        OriginalConsole.count([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    markTimeline: (message) ->
        OriginalConsole.markTimeline([].slice.call(arguments))
        Timeline.addRecord_Mark message

    #---------------------------------------------------------------------------
    lastWMLErrorMessage: ->
        OriginalConsole.lastWMLErrorMessage([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    profile: (title) ->
        OriginalConsole.profile([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    profileEnd: (title) ->
        OriginalConsole.profileEnd([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    time: (title) ->
        OriginalConsole.time([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    timeEnd: (title) ->
        OriginalConsole.timeEnd([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    group: ->
        OriginalConsole.group([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    groupCollapsed: ->
        OriginalConsole.groupCollapsed([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    groupEnd: ->
        OriginalConsole.groupEnd([].slice.call(arguments))
        Weinre.notImplemented arguments.callee.signature

#-------------------------------------------------------------------------------
RemoteConsole   = new Console()
OriginalConsole = window.console
RemoteConsole.__original   = OriginalConsole
OriginalConsole.__original = OriginalConsole
window.console = RemoteConsole

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)