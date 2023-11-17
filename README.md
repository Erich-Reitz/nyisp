# Yisp

Lisp dialect for CS 403 project


## Development Environment

This project is written in the [Nim](https://nim-lang.org/) programming language and requires version 
2.0.0 or greater. To install Nim, visit: [Install Nim](https://nim-lang.org/install.html). Building the 
project requires `Nimble` which is bundled with Nim installation. To the build the binary, execute 
`nimble build` in the project directory.

### Commands
- format: `find src/ -name "*.nim" -exec nimpretty {} \;`
- build: `nimble build`
- test: `nimble test`

### Testing
The program used for testing can be viewed at `tests/test.nim`. The program will automatically execute each test case, invoking the yisp program with a specific test file located at `tests/<testname>/<testname>.yisp`. The expected output is 
in the same folder, at `tests/<testname>/<testname>.out`.

## Usage
Run `ysip <filename>` to execute a file. There is no REPL support.

### Example Programs
#### Factorial
```
(define factorial (n)
  (cond
    ((= n 0) 1) ; base case: factorial of 0 is 1
    ((> n 0) (* n (factorial (- n 1)))) ; recursive case: n * factorial(n - 1)
  )
)

(factorial 5)
```
#### First class Functions
```
(define twice (f x)
  (f (f x))
)

(define square (x) 
  (* x x)
)

(set sq square)

(twice sq 2) ; ==> 16
```

### Fun facts
This interpreter written in nim is 1.4x times faster than my "equivalent" interpreter written in C++ when computing naive fibonacci(27).