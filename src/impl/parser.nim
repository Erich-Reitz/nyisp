import std/options

import atom
import sexpr
import token


type Parser* = object
    tokens*: seq[Token]
    current*: int = 0

proc expression(p: var Parser): SExpr

func peek(p: Parser): Token =
    p.tokens[p.current]

func isAtEnd(p: Parser): bool =
    peek(p).typ == tkEOF

func previous(p: Parser): Token =
    p.tokens[p.current - 1]

func check(p: Parser, typ: TokenType): bool =
    if isAtEnd(p):
        return false

    peek(p).typ == typ

func advance(p: var Parser): Token =
    if isAtEnd(p) == false:
        p.current += 1

    previous(p)

proc consume(p: var Parser, typ: TokenType, msg: string): Token =
    if check(p, typ) == true:
        return advance(p)

    echo "parse error:", msg
    quit(QuitFailure)

func match(p: var Parser, typ: TokenType): bool =
    if check(p, typ):
        discard advance(p)
        return true

    return false


func initParser*(tokens: seq[Token]): Parser =
    Parser(tokens: tokens)


proc atomExpression(p: var Parser): SExpr =
    if match(p, tkAtom):
        let atm = previous(p)
        assert(atm.atom.isSome, "tkAtom doesn't have Atom")

        return newExpr(get(atm.atom))

    return newExpr(initNilAtom())

proc sExpression(p: var Parser): SExpr =
    if match(p, tkRightParen):
        return newExpr(initNilAtom())

    let nilConsCell = ConsCell(car: nil, cdr: nil)
    var sentinel = newExpr(nilConsCell)

    var cur = sentinel
    while check(p, tkRightParen) == false:
        if isAtEnd(p):
            echo "parse error: unmatched parenthesis"
            quit(QuitFailure)

        let exp = expression(p)
        let newCell = newExpr(ConsCell(car: exp, cdr: nil))

        cur.consCell.cdr = newCell
        cur = newCell

    discard consume(p, tkRightParen, "expected )")

    return sentinel.consCell.cdr


proc expression(p: var Parser): SExpr =
    if match(p, tkLeftParen):
        return sExpression(p)

    return atomExpression(p)


proc parse*(tokens: seq[Token]): seq[SExpr] =
    var p = initParser(tokens)

    while isAtEnd(p) == false:
        let exp = expression(p)
        result.add(exp)




