import std/strutils

import scanner

proc gatherWhile(s: string, predicate: proc (
        c: char): bool {.closure.}): string =
    for c in s:
        if predicate(c):
            result.add(c)
        else:
            break
    return result

proc predGatherNumber(): proc(c: char): bool =
    var periodEncountered = false
    return proc(c: char): bool =
        if isDigit(c): return true

        if c == '.' and not periodEncountered:
            periodEncountered = true
            return true

        return false

proc lFloat*(str: string): float =
    let floatStr = gatherWhile(str, predGatherNumber())

    parseFloat(floatStr)


proc lStr*(s: var Scanner): string =
    while peek(s) != '"' and (isAtEnd(s) == false):
        if peek(s) == '\n':
            s.line += 1
        discard advance(s)

    if isAtEnd(s):
        echo "unterminated string"
        quit(QuitFailure)
    discard advance(s)

    s.source.substr(s.start, s.current - 1)


proc lIden*(s: var Scanner): string =
    while isAlphaAscii(peek(s)) or peek(s) == '?':
        discard advance(s)

    s.source.substr(s.start, s.current - 1)
