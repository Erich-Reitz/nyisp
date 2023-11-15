import atom
import sexpr

proc evaluate(env: var Env, exp: SExpr): SExpr
type EvalError = object of CatchableError

proc biPlus(env: var Env, args: SExpr): SExpr =
    var res: float = 0.0
    var e_ptr = args
    while e_ptr != nil:
        res += toNum(car(e_ptr))
        e_ptr = cdr(e_ptr)

    newExpr(initAtom(res))

proc biMinus(env: var Env, args: SExpr): SExpr =
    var e_ptr = args
    var res = toNum(car(e_ptr))
    e_ptr = cdr(e_ptr)
    while e_ptr != nil:
        res -= toNum(car(e_ptr))
        e_ptr = cdr(e_ptr)

    newExpr(initAtom(res))

proc biSet(env: var Env, args: SExpr): SExpr =
    let varname = toStr(car(args))
    let value = evaluate(env, cdr(args))
    env.define(varname, value)

proc evaluteArgs(env: var Env, args: SExpr): SExpr =
    if args == nil:
        return nil

    cons(evaluate(env, car(args)), evaluteArgs(env, cdr(args)))

proc apply(env: var Env, exp: SExpr, cdr: SExpr): SExpr =
    assert (exp.kind == skFn)
    var args = cdr

    if exp.delayEval == false:
        args = evaluteArgs(env, args)

    exp.fn(env, args)

proc evaluate(env: Env, a: Atom): SExpr =
    if a.kind == akIdentifier:
        let res = lookup(env, a.strVal)
        if res == nil:
            raise newException(EvalError, "undefined identifier: " & a.strVal)
        return res

    newExpr(a)

proc evaluate(env: var Env, cc: ConsCell): SExpr =
    let fn = evaluate(env, cc.first)
    case fn.kind:
    of skFn: return apply(env, fn, cc.second)
    else: return newExpr(cc)


proc evaluate(env: var Env, exp: SExpr): SExpr =
    if exp == nil:
        return nil

    case exp.kind:
    of skAtom: return evaluate(env, exp.atom)
    of skConsCell: return evaluate(env, exp.consCell)
    of skFn: return exp

proc defineBuiltins(env: var Env) =
    env.define("+", newExpr(biPlus))
    env.define("-", newExpr(biMinus))
    env.define("set", newExpr(biSet, true))

proc interpret*(expressions: seq[SExpr]): int =
    var env = newEnv()
    defineBuiltins(env)
    for exp in expressions:
        let res = evaluate(env, exp)
        echo $res

    QuitSuccess
