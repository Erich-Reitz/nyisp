import std/parseopt
import std/options

import impl/lexer
import impl/parser
import impl/interpreter

proc run(program: string): int =
    let tokens = lex(program)
    let expressions = parse(tokens)
    return interpret(expressions)

proc runfile(filename: string): int =
    try:
        let contents = readFile(filename)
        return run(contents)
    except IOError as e:
        echo e.msg
        return QuitFailure


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
