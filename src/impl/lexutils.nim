import std/strutils

import scanner


proc lFloat*(s: var Scanner): float =
    while isDigit(peek(s)):
        discard advance(s)

    if peek(s) == '.' and isDigit(peekNext(s)):
        discard advance(s)
        while isDigit(peek(s)):
            discard advance(s)

    let floatStr = s.source.substr(s.start, s.current - 1)
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

func allowedIdentifierChar(c: char): bool =
    isAlphaNumeric(c) or @['_', '?', '-'].contains(c)

proc lIden*(s: var Scanner): string =
    while allowedIdentifierChar(peek(s)):
        discard advance(s)

    s.source.substr(s.start, s.current - 1)
