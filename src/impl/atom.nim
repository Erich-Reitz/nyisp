type
  AtomKind* = enum akNil, akTrue, akNum, akString, akIdentifier

  Atom* = object
    case kind*: AtomKind
    of akNil, akTrue: _: bool
    of akString, akIdentifier: strVal*: string
    of akNum: numVal*: float

func initAtom*(num: float): Atom =
  Atom(kind: akNum, numVal: num)

func initAtom*(v: bool): Atom =
  if v == true:
    Atom(kind: akTrue)
  else:
    Atom(kind: akNil)

proc `==`*(a, b: Atom): bool =
  if a.kind != b.kind:
    result = false
  else:
    case a.kind
    of akNil, akTrue: result = true
    of akString, akIdentifier: result = a.strVal == b.strVal
    of akNum: result = a.numVal == b.numVal

func initAtom*(kind: akString..akIdentifier, str: string): Atom =
  Atom(kind: kind, strVal: str)

func initNilAtom*(): Atom =
  Atom(kind: akNil)

func toNum*(a: Atom): float =
  case a.kind
  of akNum: result = a.numVal
  else: raise newException(Exception, "a.kind != akNum")

func toStr*(a: Atom): string =
  case a.kind
  of akString, akIdentifier: result = a.strVal
  else: raise newException(Exception, "a.kind != akString")

proc `$`*(a: Atom): string =
  case a.kind
  of akNil: result = "nil"
  of akTrue: result = "t"
  of akString: result = a.strVal
  of akIdentifier: result = a.strVal
  of akNum: result = $a.numVal
