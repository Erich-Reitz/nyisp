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

- `PROCEDURE?` is implemented as a way to test if an object is a procedure

### Primitive Procedures

- `+` is implemented as the sum of its arguments. Only works over a single list of numbers
  - `(+ 1.5 1.5 1 2 3) ; => 9`

- `-` is similar, with the first argument being the minuend, rest subtrahend
  - `(- 1.5 1.5 1 2 3) ; => -6`

  - With a single argument, it will return its additive inverse.
    `(- -5) ; => 5`

- `*` provides the product
  - `(* 2 1 2 3) ; => 12`

- `mod` only takes two arguments.

- `/` only takes two arguments, and returns the quotient.

- `<`, `=`, `>` are relational operators over two numerical arguments.

- `cons` is implemented
  - `(cons expr1 expr2 ); => (expr1 . expr2)`

- `car` and `cdr` are implemented

- `NUMBER?`, `SYMBOL?`, `LIST?` and `NIL?` are implemented as expected and each take a single argument.

- `AND?` and `OR?` are lazy evaluated and take 1 or more arguments. They assess their arguments' truthiness, short-circuiting evaluation if they encounter nil (for AND) or a non-nil value (for OR).

- `list` constructs a list with its arguments.

- `quote` is implemented.

- `mapcar` is implemented
  - `(mapcar (lambda (x) (* x 2)) '(1 2 3 4 5)); => (2 4 6 8 10)`

- `filter` is implemented
  - `(filter (lambda (x) (> x 0 )) '(1 2 3 -1 -2 -3)); => (1 2 3)`


### Issues

- The document says `=`: 
  > compares the values of two atoms or (). Returns () when either expression is a larger list.

  My program does not support lists being passed to `=`. It does support the empty list ().

## Example Program
```
(define gcd (a b)
    (cond ((= b 0) a)
          (t (gcd b (mod a b)))))

(define lcm (a b)
  (/ (* a b) (gcd a b)))


(define lcm-list (lst)
  (cond 
    ((NIL? (cdr lst)) (car lst))
    (t (lcm (car lst) (lcm-list (cdr lst)))))
)

(lcm-list '(2 3)) ; => 6
(lcm-list '(2 32)) ; => 32
(lcm-list '(9 7)) ; => 54
(lcm-list '(4 5)) ; 20
```

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

