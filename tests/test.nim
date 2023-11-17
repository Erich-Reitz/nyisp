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
    var result = ""
    var i = 0
    var j = 0

    while i < original.len or j < modified.len:
        if i < original.len and j < modified.len and original[i] == modified[j]:
            # No change in this character
            result.add(original[i])
            inc(i)
            inc(j)
        elif i < original.len and (j >= modified.len or original[i] notin modified):
            # Character deleted from original
            result.add("-" & original[i])
            inc(i)
        elif j < modified.len:
            # Character added in modified
            result.add("+" & modified[j])
            inc(j)

    return result


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