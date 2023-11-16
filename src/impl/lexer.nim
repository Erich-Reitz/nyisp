import std/strutils


import atom
import lexutils
import scanner
import token

func indicatesDigit(c: char, s: Scanner): bool =
    isDigit(c) or (c == '-' and isDigit(peek(s)))

func isOperator(c: char): bool =
    @['+', '-', '*', '/', '<', '>', '='].contains(c)


func indicatesIden(c: char, s: Scanner): bool =
    isAlphaAscii(c) or isOperator(c)


proc parseNum(s: var Scanner) =
    let num = lFloat(s)
    let atm = initAtom(num)
    let token = initToken(atm, s.line)

    s.addToken(token)


proc parseString(s: var Scanner) =
    let strContents = lStr(s)
    let atm = initAtom(akString, strContents)
    let token = initToken(atm, s.line)

    s.addToken(token)


func parseIden(s: var Scanner) =
    let iden = lIden(s)
    let atm = initAtom(akIdentifier, iden)
    let token = initToken(atm, s.line)

    s.addToken(token)

proc scanToken(s: var Scanner) =
    let c = advance(s)
    case c:
    of '(':
        addToken(s, tkLeftParen)
    of ')':
        addToken(s, tkRightParen)
    of ';':
        while ((peek(s) != '\n') and (isAtEnd(s) == false)):
            discard advance(s)
    of ' ', '\r', '\t':
        discard
    of '\n':
        s.line += 1
    of '"':
        parseString(s)
    else:
        if indicatesDigit(c, s) == true:
            parseNum(s)
        elif indicatesIden(c, s) == true:
            parseIden(s)
        else:
            echo "Unexpected character: ", c
            quit(QuitFailure)


proc lex*(program: string): seq[Token] =
    var s = Scanner(source: program)
    while isAtEnd(s) == false:
        s.start = s.current
        scanToken(s)

    s.tokens.add(initToken(tkEOF, s.line+1))

    return s.tokens

