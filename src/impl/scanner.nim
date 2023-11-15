import token

type Scanner* = object
    source*: string
    start*: int = 0
    current*: int = 0
    line*: int = 1
    tokens*: seq[Token] = @[]

func isAtEnd*(s: Scanner): bool =
    s.current >= len(s.source)

func advance*(s: var Scanner): char =
    result = s.source[s.current]
    s.current = s.current + 1

func addToken*(s: var Scanner, tokType: TokenType) =
    let line = s.line

    let token = initToken(tokType, line)
    s.tokens.add(token)

func addToken*(s: var Scanner, token: Token) =
    s.tokens.add(token)

func peek*(s: Scanner): char =
    if isAtEnd(s):
        return '\n'

    s.source[s.current]







