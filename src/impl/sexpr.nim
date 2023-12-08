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

func newExpr*(cc: ConsCell): SExpr =
    SExpr(kind: skConsCell, consCell: cc)

func newFnExpr*(fn: proc (env: var Env, args: SExpr): SExpr): SExpr =
    SExpr(kind: skFn, fn: fn)

func newFnExpr*(fn: proc (env: var Env, args: SExpr): SExpr,
        delayEval: bool): SExpr =
    SExpr(kind: skFn, fn: fn, delayEval: delayEval)

func newFnExpr*(fn: proc (env: var Env, args: SExpr): SExpr,
        delayEval: bool, arity: int): SExpr =
    SExpr(kind: skFn, fn: fn, delayEval: delayEval, arity: some(arity))

func newFnExpr*(fn: proc (env: var Env, args: SExpr): SExpr,
     arity: int): SExpr =
    SExpr(kind: skFn, fn: fn, arity: some(arity))

func toNum*(s: SExpr): float =
    case s.kind:
    of skAtom:
        return toNum(s.atom)
    else:
        raise newException(Exception, "s.kind != skAtom")


func toNum*(cc: ConsCell): float =
    if cc.car.kind != skAtom:
        raise newException(Exception, "c.car.kind != skAtom")

    return toNum(cc.car.atom)

func toStr*(s: SExpr): string =
    case s.kind:
    of skAtom:
        return toStr(s.atom)
    else:
        return toStr(s.consCell.car)

func toStr*(cc: ConsCell): string =
    if cc.car.kind != skAtom:
        raise newException(Exception, "c.car.kind != skAtom")

    return toStr(cc.car.atom)


func car*(s: SExpr): SExpr =
    if s.kind != skConsCell:
        # TODO: I don't know
        return s

    return s.consCell.car


func cdr*(s: SExpr): SExpr =
    if s.kind != skConsCell:
        # TODO: I don't know
        return SExpr(kind: skAtom, atom: initNilAtom())

    return s.consCell.cdr

func setCdr*(s: SExpr, cdr: SExpr) =
    if s.kind != skConsCell:
        raise newException(Exception, "s.kind != skConsCell")

    s.consCell.cdr = cdr

proc `$`*(e: SExpr): string

proc len*(args: SExpr): int =
    if args.kind == skAtom:
        return 1
    if args.kind == skConsCell:
        if args.cdr == nil:
            return 1
        return 1 + len(args.cdr)

    raise newException(Exception, "args.kind != skAtom and args.kind != skConsCell")

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

func lookup*(env: Env, s: string): SExpr =
    if env.vars.contains(s):
        return env.vars[s]

    return nil

func define*(env: Env, s: string, v: SExpr) =
    env.vars[s] = v


proc `$`*(e: SExpr): string =
    if e == nil: return "nil"
    case e.kind
    of skAtom: return $e.atom
    of skConsCell:
        result = "("
        var currentCell = e.consCell
        var isfirst = true
        while true:
            if isfirst == false: result.add " "
            result &= $currentCell.car
            isfirst = false

            let cdr = currentCell.cdr
            if cdr != nil:
                if cdr.kind == skConsCell:
                    currentCell = cdr.consCell
                else:
                    result &= " " & $cdr.atom
                    break
            else:
                break

        result.add ")"
    of skFn:
        result = "<fn>"
