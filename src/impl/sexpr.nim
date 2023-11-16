import std/options
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
            arity*: Option[int]

    ConsCell* = object
        car*: SExpr
        cdr*: SExpr

    Env* = ref object of RootObj
        vars*: Table[string, SExpr]


func newExpr*(a: Atom): SExpr =
    SExpr(kind: skAtom, atom: a)

func newExpr*(c: ConsCell): SExpr =
    SExpr(kind: skConsCell, consCell: c)


func newFnExpr*(fn: proc (e: var Env, args: SExpr): SExpr): SExpr =
    SExpr(kind: skFn, fn: fn)

func newFnExpr*(fn: proc (e: var Env, args: SExpr): SExpr,
        delayEval: bool): SExpr =
    SExpr(kind: skFn, fn: fn, delayEval: delayEval)

func newFnExpr*(fn: proc (e: var Env, args: SExpr): SExpr,
        delayEval: bool, arity: int): SExpr =
    SExpr(kind: skFn, fn: fn, delayEval: delayEval, arity: some(arity))

func newFnExpr*(fn: proc (e: var Env, args: SExpr): SExpr,
     arity: int): SExpr =
    SExpr(kind: skFn, fn: fn, arity: some(arity))




func toNum*(s: SExpr): float =
    case s.kind:
    of skAtom:
        return toNum(s.atom)
    else:
        return toNum(s.consCell.car)

func toNum*(c: ConsCell): float =
    if c.car.kind != skAtom:
        raise newException(Exception, "c.car.kind != skAtom")

    return toNum(c.car.atom)

func toStr*(s: SExpr): string =
    case s.kind:
    of skAtom:
        return toStr(s.atom)
    else:
        return toStr(s.consCell.car)

func toStr*(c: ConsCell): string =
    if c.car.kind != skAtom:
        raise newException(Exception, "c.car.kind != skAtom")

    return toStr(c.car.atom)



func car*(s: SExpr): SExpr =
    if s.kind != skConsCell:
        raise newException(Exception, "s.kind != skConsCell")

    return s.consCell.car


func cdr*(s: SExpr): SExpr =
    if s.kind != skConsCell:
        raise newException(Exception, "s.kind != skConsCell")

    return s.consCell.cdr

func setCdr*(s: SExpr, cdr: SExpr) =
    if s.kind != skConsCell:
        raise newException(Exception, "s.kind != skConsCell")

    s.consCell.cdr = cdr


func isNilExpr*(s: SExpr): bool =
    return s == nil or (s.kind == skAtom and s.atom.kind == akNil)


func equalValues*(a, b: SExpr): bool =
    if a == nil and b == nil: return true
    if a == nil or b == nil: return false

    if a.kind != b.kind: return false

    case a.kind
    of skAtom:
        return a.atom == b.atom
    else:
        raise newException(Exception, "kind != skAtom")


func cons*(a, b: SExpr): SExpr =
    return newExpr(ConsCell(car: a, cdr: b))

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
        if e.consCell.car.kind == skAtom and e.consCell.cdr == nil:
            return $e.consCell.car.atom

        result = "("
        var currentCell = e.consCell
        var isfirst = true
        while true:
            if isfirst == false: result.add " "
            result &= $currentCell.car

            isfirst = false

            let cdr = currentCell.cdr
            if cdr == nil: break
            currentCell = cdr.consCell

        result.add ")"
    of skFn:
        result = "<fn>"
