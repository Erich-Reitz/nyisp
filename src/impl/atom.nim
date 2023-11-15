import atomkind

type
  Atom* = object
    case kind*: AtomKind
    of akNil, akTrue: _: bool
    of akString, akIdentifier: strVal: string
    of akNumber: numVal: float

func initAtom*(num: float): Atom =
  Atom(kind: akNumber, numVal: num)

# hfs thats awesome
func initAtom*(kind: akString..akIdentifier, str: string): Atom =
  Atom(kind: kind, strVal: str)

func initNilAtom*(): Atom =
  Atom(kind: akNil)

proc `$`*(a: Atom): string =
  case a.kind
  of akNil: result = "nil"
  of akTrue: result = "true"
  of akString: result = a.strVal
  of akIdentifier: result = a.strVal
  of akNumber: result = $a.numVal
