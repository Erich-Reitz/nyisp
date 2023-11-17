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
  
proc runTest(testname: string): bool =
  let output = runTestFile(testname)
  let expectedOutput = expectedTestOutput(testname)

  if output == expectedOutput:
    return true
  
  echo "test failed: " & testname
  echo "expected output:"
  echo expectedOutput
  echo "actual output:"
  echo output
  return false


suite "integration tests":
  setup:
    # compile main program
    let res = osproc.execCmd("nimble build")
    if res != 0:
      echo "failed to compile"
      quit(QuitFailure)
    
  test "factorial":
    check runTest("factorial") 
  
  test "addition":
    check runTest("addition")

  test "firstclassfunctions":
    check runTest("firstclassfunctions")
  
  test "lambda":
    check runTest("lambda")