import sexpression


proc evaluate(exp: SExpr): SExpr =
    return exp

proc interpret*(expressions: seq[SExpr]): int =
    for exp in expressions:
        let res = evaluate(exp)
        echo $res

    QuitSuccess
