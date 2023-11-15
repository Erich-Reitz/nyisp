import std/parseopt
import std/options

import yisp

proc main() =
    var filename = none(string)

    var p = initOptParser("")
    while true:
        p.next()
        case p.kind:
        of cmdEnd: break
        of cmdShortOption, cmdLongOption:
            break
        of cmdArgument:
            if isSome(filename):
                echo("usage: ysip <filename>")
                quit(QuitFailure)

            filename = some(p.key)

    if isNone(filename):
        echo("usage: ysip <filename>")
        quit(QuitFailure)

    quit(runfile(get(filename)))



when isMainModule:
    main()
