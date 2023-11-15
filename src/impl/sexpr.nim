import std/tables

import atom

type



    SExprKind* = enum skAtom, skConsCell, skFn
    SExpr* = ref object of RootObj
        case kind*: SExprKind
        of skAtom: atom*: Atom
        of skConsCell: consCell*: ConsCell
        of skFn:
            fn*: proc (e: var Env, args: SExpr): SExpr
            delayEval*: bool = false

    ConsCell* = object
        first*: SExpr
        second*: SExpr

    Env* = ref object of RootObj
        vars: Table[string, SExpr]


func newExpr*(a: Atom): SExpr =
    SExpr(kind: skAtom, atom: a)

func newExpr*(c: ConsCell): SExpr =
    SExpr(kind: skConsCell, consCell: c)


func newExpr*(p: proc (e: var Env, args: SExpr): SExpr): SExpr =
    SExpr(kind: skFn, fn: p)

func newExpr*(p: proc (e: var Env, args: SExpr): SExpr,
        delayEval: bool): SExpr =
    SExpr(kind: skFn, fn: p, delayEval: delayEval)

func toNum*(s: SExpr): float =
    case s.kind:
    of skAtom:
        return toNum(s.atom)
    else:
        return toNum(s.consCell.first)

func toNum*(c: ConsCell): float =
    if c.first.kind != skAtom:
        raise newException(Exception, "c.first.kind != skAtom")

    return toNum(c.first.atom)

func toStr*(s: SExpr): string =
    case s.kind:
    of skAtom:
        return toStr(s.atom)
    else:
        return toStr(s.consCell.first)

func toStr*(c: ConsCell): string =
    if c.first.kind != skAtom:
        raise newException(Exception, "c.first.kind != skAtom")

    return toStr(c.first.atom)


func car*(c: ConsCell): SExpr =
    return c.first

func cdr*(c: ConsCell): SExpr =
    return c.second


func car*(s: SExpr): SExpr =
    if s.kind != skConsCell:
        raise newException(Exception, "s.kind != skConsCell")

    return car(s.consCell)


func cdr*(s: SExpr): SExpr =
    if s.kind != skConsCell:
        raise newException(Exception, "s.kind != skConsCell")

    return cdr(s.consCell)

func cons*(a: SExpr, b: SExpr): SExpr =
    return newExpr(ConsCell(first: a, second: b))

func newEnv*(): Env =
    result = Env(vars: initTable[string, SExpr]())

func lookup*(e: Env, s: string): SExpr =
    if e.vars.contains(s):
        return e.vars[s]

    return nil

func define*(e: Env, s: string, v: SExpr) =
    e.vars[s] = v

proc `$`*(e: SExpr): string =
    if e == nil: return "nil"
    case e.kind
    of skAtom: return $e.atom
    of skConsCell:
        if e.consCell.first.kind == skAtom and e.consCell.second == nil:
            return $e.consCell.first.atom

        result = "("
        var currentCell = e.consCell
        var isfirst = true
        while true:
            if isfirst == false: result.add " "
            result &= $currentCell.first

            isfirst = false

            let cdr = currentCell.second
            if cdr == nil: break
            currentCell = cdr.consCell

        result.add ")"
    of skFn:
        result = "<fn>"
