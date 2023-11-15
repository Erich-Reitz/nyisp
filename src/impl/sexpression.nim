import atom
import atomkind

type
    SExprKind = enum skAtom, skConsCell
    SExpr* = ref object of RootObj
        case kind*: SExprKind
        of skAtom: atom*: Atom
        of skConsCell: consCell*: ConsCell

    ConsCell* = object
        first*: SExpr
        second*: SExpr

func newExpr*(a: Atom): SExpr =
    SExpr(kind: skAtom, atom: a)

func newExpr*(c: ConsCell): SExpr =
    SExpr(kind: skConsCell, consCell: c)

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
            result &= $currentCell.first

            isfirst = false

            let cdr = currentCell.second
            if cdr == nil: break


            currentCell = cdr.consCell
        result.add ")"
