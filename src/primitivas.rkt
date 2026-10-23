#lang eopl
;Autores: Adriana Milena Noscue Dagua 2477336, Sebastian Cucalon Astorquiza 2477344
;Santiago Torres Rojas 2380301, Nicolle Camila Hoyos Puin 2380608

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.
;;
;; Aridades: +, -, *, / son n-arias; add1, sub1, not y abs son unarias;
;; las relacionales, and, or, xor e implica son binarias; entre es
;; ternaria; mcd y mcm son n-arias sobre enteros con al menos dos
;; argumentos; promedio es n-aria sobre números con al menos uno.

(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son números; si no, levantax
;; eopl:error a nombre de quien hizo la verificación.
(define exigir-numeros
  (lambda (args quien)
    (cond
      ((null? args) #t)
      ((number? (car args))
       (exigir-numeros (cdr args) quien))
      (else
       (eopl:error quien "Todos los argumentos deben ser números")))))

;; exigir-enteros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son enteros; si no, levanta error.
(define exigir-enteros
  (lambda (args quien)
    (cond
      ((null? args) #t)
      ((integer? (car args))
       (exigir-enteros (cdr args) quien))
      (else
       (eopl:error quien "Todos los argumentos deben ser enteros")))))

;; exigir-booleanos : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son booleanos; si no, levanta error.
(define exigir-booleanos
  (lambda (args quien)
    (cond
      ((null? args) #t)
      ((boolean? (car args))
       (exigir-booleanos (cdr args) quien))
      (else
       (eopl:error quien "Todos los argumentos deben ser booleanos")))))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Retorna #t si llegaron exactamente n argumentos; si no, levanta error.
(define exigir-cantidad
  (lambda (args n quien)
    (if (= (length args) n)
        #t
        (eopl:error quien "Cantidad incorrecta de argumentos"))))

;; exigir-minimo : lista x int x symbol -> boolean
;; Retorna #t si llegaron al menos n argumentos; si no, levanta error.
(define exigir-minimo
  (lambda (args n quien)
    (if (>= (length args) n)
        #t
        (eopl:error quien "Faltan argumentos"))))

;; evaluar-primitiva : primitiva x lista de valores -> valor
;; Verifica la cantidad y el tipo de los argumentos y aplica la
;; primitiva. Se resuelve con cases sobre el datatype primitiva.

(define evaluar-primitiva
  (lambda (prim args)
    (cases primitiva prim
      (sum-prim ()
        (exigir-numeros args '+)
        (apply + args))

      (minus-prim ()
        (exigir-minimo args 1 '-)
        (exigir-numeros args '-)
        (if (null? (cdr args))
            (- (car args))
            (- (car args) (apply + (cdr args)))))

      (mult-prim ()
        (exigir-numeros args '*)
        (apply * args))

      (div-prim ()
        (exigir-minimo args 1 '/)
        (exigir-numeros args '/)
        (if (null? (cdr args))
            (if (= (car args) 0)
                (eopl:error '/ "Division entre cero")
                (/ 1 (car args)))
                        (if (member 0 (cdr args))
                (eopl:error '/ "Division entre cero")
                (/ (car args) (apply * (cdr args))))))

        (add-prim ()
         (exigir-cantidad args 1 'add1)
         (exigir-numeros args 'add1)
         (+ (car args) 1)) 
        (sub-prim ()
         (exigir-cantidad args 1 'sub1)
         (exigir-numeros args 'sub1)
          (- (car args) 1))

      (mayor-prim ()
        (exigir-cantidad args 2 '>)
        (exigir-numeros args '>)
        (> (car args) (cadr args)))

      (mayorigual-prim ()
        (exigir-cantidad args 2 '>=)
        (exigir-numeros args '>=)
        (>= (car args) (cadr args)))

      (menor-prim ()
        (exigir-cantidad args 2 '<)
        (exigir-numeros args '<)
        (< (car args) (cadr args)))

      (menorigual-prim ()
        (exigir-cantidad args 2 '<=)
        (exigir-numeros args '<=)
        (<= (car args) (cadr args)))

      (igual-prim ()
        (exigir-cantidad args 2 '==)
        (exigir-numeros args '==)
        (= (car args) (cadr args)))

      (not-prim ()
        (exigir-cantidad args 1 'not)
        (exigir-booleanos args 'not)
        (not (car args)))

      (and-prim ()
        (exigir-cantidad args 2 'and)
        (exigir-booleanos args 'and)
        (and (car args) (cadr args)))

      (or-prim ()
        (exigir-cantidad args 2 'or)
        (exigir-booleanos args 'or)
        (or (car args) (cadr args)))

      ;; PARTE 2: PRIMITIVAS NUEVAS

      ;; abs : lista(numero) -> numero
      ;; Retorna el valor absoluto del numero ingresado.
      (abs-prim ()
        (exigir-cantidad args 1 'abs)
        (exigir-numeros args 'abs)
        (abs (car args)))

      ;; mcd : lista(entero, entero, ...) -> entero
      ;; Retorna el maximo comun divisor de n >= 2 enteros.
      (mcd-prim ()
        (exigir-minimo args 2 'mcd)
        (exigir-enteros args 'mcd)
        (apply gcd args))

      ;; mcm : lista(entero, entero, ...) -> entero
      ;; Retorna el minimo comun multiplo de n >= 2 enteros.
      (mcm-prim ()
        (exigir-minimo args 2 'mcm)
        (exigir-enteros args 'mcm)
        (apply lcm args))

      ;; promedio : lista(numero, ...) -> numero
      ;; Retorna la media aritmetica de n >= 1 numeros.
      (promedio-prim ()
        (exigir-minimo args 1 'promedio)
        (exigir-numeros args 'promedio)
        (/ (apply + args) (length args)))

      ;; xor : lista(booleano, booleano) -> booleano
      ;; Retorna verdadero si exactamente uno de los dos argumentos es verdadero.
      (xor-prim ()
        (exigir-cantidad args 2 'xor)
        (exigir-booleanos args 'xor)
        (not (eq? (car args) (cadr args))))

      ;; implica : lista(booleano, booleano) -> booleano
      ;; Retorna falso unicamente cuando el primer argumento es verdadero y el segundo es falso.
      (implica-prim ()
        (exigir-cantidad args 2 'implica)
        (exigir-booleanos args 'implica)
        (or (not (car args)) (cadr args)))

      ;; entre : lista(numero, numero, numero) -> booleano
      ;; entre(x, a, b) retorna verdadero si a <= x <= b.
      (entre-prim ()
        (exigir-cantidad args 3 'entre)
        (exigir-numeros args 'entre)
        (and (<= (cadr args) (car args))
             (<= (car args) (caddr args))))

      (else
        (eopl:error 'evaluar-primitiva
                    "Primitiva no implementada")))))


(provide (all-defined-out))
