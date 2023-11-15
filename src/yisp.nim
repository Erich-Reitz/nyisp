import impl/lexer
import impl/parser
import impl/interpreter

proc run(program: string): int =
    let tokens = lex(program)
    let expressions = parse(tokens)
    return interpret(expressions)

proc runfile*(filename: string): int =
    try:
        let contents = readFile(filename)
        return run(contents)
    except IOError as e:
        echo e.msg
        return QuitFailure

