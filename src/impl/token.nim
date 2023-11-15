import std/options

import atom


type
  TokenType* = enum
    tkLeftParen, tkRightParen, tkAtom, tkEOF

  Token* = object
    typ*: TokenType
    atom*: Option[Atom]
    line*: int

func initToken*(typ: TokenType, line: int): Token =
  Token(typ: typ, line: line)

func initToken*(atm: Atom, line: int): Token =
  Token(typ: tkAtom, atom: some(atm), line: line)
