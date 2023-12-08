# Yisp

Lisp dialect for CS 403 project


## Definitions/Semantics:
Language taken from [groups.csail.mit.edu](https://groups.csail.mit.edu/mac/ftpdir/scheme-7.4/doc-html/scheme_3.html)


### Special Forms

- `lambda` is implemented:
  - `lambda (args) expr`

- `set` is implemented:
  - `set iden expr` and `expr` is evaluated immediately in the current environment. 

- `define` is implemented:
  - `define iden (args) expr`

- `cond` is implemented and is lazy evaluated

- `if` is not implemented

### Procedure Operations

- `apply` is implemented
  - `apply procedure list`

- `procedureQ` is implemented as a way to test if an object is a procedure

### Primitive Procedures


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
#### Lambdas, first class functions
```
(set square (lambda (x) (* x x)))
(square 36)
```

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