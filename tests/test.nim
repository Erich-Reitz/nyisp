import std/osproc
import std/unittest

func testFileLocation(testname: string): string =
  "tests/" & testname & "/" & testname & ".yisp"

func testOutputLocation(testname: string): string =
  "tests/" & testname & "/" & testname & ".out"

proc expectedTestOutput(testname: string): string =
  readFile(testOutputLocation(testname))

proc execTestCaptureOutput(testname: string): (string, int) =
  osproc.execCmdEx("./yisp " & testFileLocation(testname))


proc runTestFile(testname: string): string =
  let (output, exitcode) = execTestCaptureOutput(testname)
  assert exitcode == 0
  return output

proc annotateStringDiff(original: string, modified: string): string =
    var i = 0
    var j = 0

    while i < original.len or j < modified.len:
        if i < original.len and j < modified.len and original[i] == modified[j]:
            result.add(original[i])
            inc(i)
            inc(j)
        elif i < original.len and (j >= modified.len or original[i] notin modified):
            result.add("-" & original[i])
            inc(i)
        elif j < modified.len:
            result.add("+" & modified[j])
            inc(j)


proc runTest(testname: string): bool =
  let output = runTestFile(testname)
  let expectedOutput = expectedTestOutput(testname)

  result = output == expectedOutput
  if result == false:
    echo annotateStringDiff(output, expectedOutput)

suite "integration tests":
  # compile main program once before executing tests
  let res = osproc.execCmd("nimble build")
  if res != 0:
    echo "failed to compile"
    quit(QuitFailure)
  
  setup:
    discard
    
  test "factorial":
    check runTest("factorial") 
  
  test "addition":
    check runTest("addition")

  test "firstclassfunctions":
    check runTest("firstclassfunctions")
  
  test "lambda":
    check runTest("lambda")

  test "minus":
    check runTest("minus")
  
  test "mult":
    check runTest("mult")

  test "div":
    check runTest("div")

  test "and":
    check runTest("and")

  test "or":
    check runTest("or")

  test "listQ":
    check runTest("listQ")

  test "nestedop":
    check runTest("nestedop")
  
  test "numberQ":
    check runTest("numberQ")
  
  test "symbolQ":
    check runTest("symbolQ")

  test "nilQ":
    check runTest("nilQ") 

  test "basicvar":
    check runTest("basicvar")
  
  test "car":
    check runTest("car")
  
  test "cdr":
    check runTest("cdr")

  test "cond":
    check runTest("cond")
  
  test "cons":
    check runTest("cons")
  
  test "eq":
    check runTest("eq")
  
  test "greater":
    check runTest("greater") 
  
  test "less":
    check runTest("less") 
  
  test "list":
    check runTest("list") 
  
  test "numlit":
    check runTest("numlit") 
  
  test "strlit":
    check runTest("strlit")
  
  test "sum2":
    check runTest("sum2") 

  test "apply":
    check runTest("apply")
  
  test "mapcar":
    check runTest("mapcar") 
  
  test "hypheniden":
    check runTest("hypheniden") 
    