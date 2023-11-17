import std/options

import atom
import sexpr

proc evaluate(env: var Env, exp: SExpr): SExpr
type EvalError = object of CatchableError

proc biEqual(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom(equalValues(car(args), car(cdr(args)))))

proc biLess(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom(toNum(car(args)) < toNum(car(cdr(args)))))

proc biGreater(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom(toNum(car(args)) > toNum(car(cdr(args)))))

proc biCar(env: var Env, args: SExpr): SExpr =
    result = car(car(args))
    if result == nil:
        raise newException(EvalError, "car of empty list")

proc biCdr(env: var Env, args: SExpr): SExpr =
    result = cdr(car(args))
    if result == nil:
        raise newException(EvalError, "cdr of empty list")


proc biPlus(env: var Env, args: SExpr): SExpr =
    var res: float = 0.0
    var ePtr = args
    while ePtr != nil:
        res += toNum(car(ePtr))
        ePtr = cdr(ePtr)

    newExpr(initAtom(res))

proc biMinus(env: var Env, args: SExpr): SExpr =
    var ePtr = args
    var res = toNum(car(ePtr))
    ePtr = cdr(ePtr)
    while ePtr != nil:
        res -= toNum(car(ePtr))
        ePtr = cdr(ePtr)

    newExpr(initAtom(res))

proc biStar(env: var Env, args: SExpr): SExpr =
    var res: float = 1.0
    var ePtr = args
    while ePtr != nil:
        res *= toNum(car(ePtr))
        ePtr = cdr(ePtr)

    newExpr(initAtom(res))


proc biSlash(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom((toNum(car(args))) / toNum(car(cdr(args)))))


proc biSet(env: var Env, args: SExpr): SExpr =
    var it = args
    let varname = toStr(car(it))
    it = cdr(it)
    let value = evaluate(env, car(it))
    env.define(varname, value)


proc biDefine(env: var Env, args: SExpr): SExpr =
    var it = args
    let fnName = toStr(car(it))
    it = cdr(it)
    let paramExpr = car(it)
    it = cdr(it)
    let body = car(it)

    let newFn = proc(e: var Env, args: SExpr): SExpr =
        var localEnv = newEnv()
        localEnv.vars = e.vars

        var paramIt = paramExpr
        var argIt = args


        while paramIt != nil and argIt != nil and paramIt.kind == skConsCell:
            let paramName = toStr(car(paramIt))
            let argValue = evaluate(localEnv, car(argIt))
            define(localEnv, paramName, argValue)

            paramIt = cdr(paramIt)
            argIt = cdr(argIt)

        return evaluate(localEnv, body)


    define(env, fnName, newFnExpr(fn = newFn, arity = len(paramExpr)))

    newExpr(initAtom(akIdentifier, fnName))

proc biNUMBERQ(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom(car(args).kind == skAtom and car(args).atom.kind == akNum))

proc biSYMBOLQ(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom(car(args).kind == skAtom and car(args).atom.kind == akIdentifier))

proc biLISTQ(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom(car(args).kind != skAtom))

proc biNILQ(env: var Env, args: SExpr): SExpr =
    newExpr(initAtom(car(args).kind == skAtom and car(args).atom.kind == akNil))

proc biANDQ(env: var Env, args: SExpr): SExpr =
    var ePtr = args
    while ePtr != nil:
        if isNilExpr(evaluate(env, car(ePtr))):
            return newExpr(initAtom(false))

        ePtr = cdr(ePtr)

    newExpr(initAtom(true))

proc biORQ(env: var Env, args: SExpr): SExpr =
    var ePtr = args
    while ePtr != nil:
        if isNilExpr(evaluate(env, car(ePtr))) == false:
            return newExpr(initAtom(true))

        ePtr = cdr(ePtr)

    newExpr(initAtom(false))


proc biCons(env: var Env, args: SExpr): SExpr =
    cons(evaluate(env, car(args)), evaluate(env, cdr(args)))


proc biList(env: var Env, args: SExpr): SExpr =
    if args == nil:
        return nil

    var argit = args
    var evaluated = evaluate(env, car(argit))
    var head = cons(evaluated, nil)
    var cur = head

    argit = cdr(argit)

    while argit != nil:
        cur.setCdr(cons(evaluate(env, car(argit)), nil))
        cur = cur.cdr
        argit = cdr(argit)

    head


proc biCond(env: var Env, args: SExpr): SExpr =
    var condValuePair = args
    while condValuePair != nil:
        let cond = car(car(condValuePair))
        let resultExpr = cdr(car(condValuePair))
        let conditionResult = evaluate(env, cond)
        if isNilExpr(conditionResult) == false:
            return evaluate(env, resultExpr)

        condValuePair = cdr(condValuePair)

    newExpr(initAtom(false))


proc biQuote(env: var Env, args: SExpr): SExpr =
    car(args)


proc biLambda(env: var Env, args: SExpr): SExpr =
    let paramExpr = car(args)
    let body = cdr(args)

    # <copy>
    let definedVariables = env.vars

    let newFn = proc(e: var Env, args: SExpr): SExpr =
        var localEnv = newEnv()
        # <place>
        localEnv.vars = definedVariables

        var paramIt = paramExpr
        var argIt = args

        while paramIt != nil and argIt != nil and paramIt.kind == skConsCell:
            let paramName = toStr(car(paramIt))
            let argValue = evaluate(localEnv, car(argIt))
            define(localEnv, paramName, argValue)

            paramIt = cdr(paramIt)
            argIt = cdr(argIt)

        return evaluate(localEnv, body)

    return newFnExpr(newFn)


proc evaluteArgs(env: var Env, args: SExpr): SExpr =
    if args == nil:
        return nil

    cons(evaluate(env, car(args)), evaluteArgs(env, cdr(args)))


proc assertArity(exp: SExpr, args: SExpr): SExpr =
    if isSome(exp.arity) and len(args) != exp.arity.get:
        raise newException(EvalError, "wrong number of arguments: " &
                $exp.arity.get & " expected, got " & $len(args))

    args


proc processArgs(env: var Env, fnExpr: SExpr, args: SExpr): SExpr =
    assert (fnExpr.kind == skFn)
    if fnExpr.delayEval == false:
        return assertArity(fnExpr, evaluteArgs(env, args))

    return assertArity(fnExpr, args)

proc doFn(env: var Env, exp: SExpr, args: SExpr): SExpr =
    exp.fn(env, processArgs(env, exp, args))

proc evaluate(env: Env, a: Atom): SExpr =
    if a.kind == akIdentifier:
        let res = lookup(env, a.strVal)
        if res == nil:
            raise newException(EvalError, "undefined identifier: " & a.strVal)
        return res

    newExpr(a)

proc evaluate(env: var Env, cc: ConsCell): SExpr =
    if cc.cdr == nil:
        return evaluate(env, cc.car)

    let fn = evaluate(env, cc.car)
    case fn.kind:
    of skFn: result = doFn(env, fn, cc.cdr)
    else: result = newExpr(cc)


proc evaluate(env: var Env, exp: SExpr): SExpr =
    if exp == nil:
        return nil

    case exp.kind:
    of skAtom: result = evaluate(env, exp.atom)
    of skConsCell: result = evaluate(env, exp.consCell)
    of skFn: result = exp

proc defineBuiltins(env: var Env) =
    # operators
    env.define("+", newFnExpr(fn = biPlus))
    env.define("-", newFnExpr(fn = biMinus))
    env.define("*", newFnExpr(fn = biStar))
    env.define("/", newFnExpr(fn = biSlash, arity = 2))
    env.define("<", newFnExpr(fn = biLess, arity = 2))
    env.define(">", newFnExpr(fn = biGreater, arity = 2))
    env.define("=", newFnExpr(fn = biEqual, arity = 2))

    env.define("NUMBER?", newFnExpr(fn = biNUMBERQ, arity = 1))
    env.define("SYMBOL?", newFnExpr(fn = biSYMBOLQ, arity = 1))
    env.define("LIST?", newFnExpr(fn = biLISTQ, arity = 1))
    env.define("NIL?", newFnExpr(fn = biNILQ, arity = 1))

    env.define("AND?", newFnExpr(fn = biANDQ, delayEval = true))
    env.define("OR?", newFnExpr(fn = biORQ, delayEval = true))

    env.define("define", newFnExpr(fn = biDefine, delayEval = true, arity = 3))
    env.define("set", newFnExpr(fn = biSet, delayEval = true, arity = 2))
    env.define("car", newFnExpr(fn = biCar, arity = 1))
    env.define("cdr", newFnExpr(fn = biCdr, arity = 1))
    env.define("cons", newFnExpr(fn = biCons, arity = 2))
    env.define("list", newFnExpr(fn = biList))
    env.define("cond", newFnExpr(fn = biCond, delayEval = true))
    env.define("quote", newFnExpr(fn = biQuote, delayEval = true, arity = 1))
    env.define("lambda", newFnExpr(fn = biLambda, delayEval = true, arity = 2))


proc interpret*(expressions: seq[SExpr]): int =
    var env = newEnv()
    defineBuiltins(env)
    for exp in expressions:

        let res = evaluate(env, exp)
        echo $res

    QuitSuccess
