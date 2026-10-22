#lang eopl
;Autores: Adriana Milena Noscue Dagua 2477336, Sebastian Cucalon Astorquiza 2477344
;Santiago Torres Rojas 2380301, Nicolle Camila Hoyos Puin 2380608

;; Taller 2 — El intérprete de Cauca.
;; El recorrido de la sintaxis abstracta y la aplicación de
;; procedimientos. Requiere sintaxis.rkt, valores.rkt, ambiente.rkt y
;; primitivas.rkt.
;;
;; apply-procedure vive aquí y no en valores.rkt porque llama a
;; evaluar-expresion.

(require "sintaxis.rkt")
(require "valores.rkt")
(require "ambiente.rkt")
(require "primitivas.rkt")

;; apply-procedure : procval x lista de valores -> valor
;; Verifica que la cantidad de argumentos coincida con la de parámetros
;; y evalúa el cuerpo en el ambiente de la clausura extendido con las
;; ligaduras de los parámetros, no en el ambiente de la llamada.

(define apply-procedure
  (lambda (proc args)
    (cases procval proc
      (cerradura (ids body env)
        (if (= (length ids) (length args))
            (evaluar-expresion
             body
             (ambiente-extendido ids args env))
            (eopl:error 'apply-procedure
                        "Cantidad incorrecta de argumentos"))))))


;; evaluar-programa : programa -> valor
;; Punto de entrada: evalúa la expresión del programa en el ambiente
;; inicial.

(define evaluar-programa
  (lambda (pgm)
    (cases programa pgm
      (a-program (exp)
        (evaluar-expresion exp (ambiente-inicial))))))


;; evaluar-rands : lista de expresiones x ambiente -> lista de valores
;; Evalúa las expresiones de izquierda a derecha en el mismo ambiente.

(define evaluar-rands
  (lambda (rands env)
    (if (null? rands)
        '()
        (cons
         (evaluar-expresion (car rands) env)
         (evaluar-rands (cdr rands) env)))))


;; evaluar-expresion : expresion x ambiente -> valor
;; Recorre el árbol de sintaxis abstracta con cases y evalúa cada
;; variante según la semántica del enunciado. El if liga el resultado de
;; la condición a test-value, lo verifica con boolean? y solo entonces
;; ramifica; el case evalúa la expresión de control una sola vez.

(define evaluar-expresion
  (lambda (exp env)
    (cases expresion exp

      (lit-exp (numero)
        numero)

      (var-exp (id)
        (apply-env env id))

      (true-exp ()
        #t)

      (false-exp ()
        #f)

      (prim-exp (prim rands)
        (evaluar-primitiva
         prim
         (evaluar-rands rands env)))

      (if-exp (test-exp then-exp else-exp)
        (let ((test-value (evaluar-expresion test-exp env)))
          (if (boolean? test-value)
              (if test-value
                  (evaluar-expresion then-exp env)
                  (evaluar-expresion else-exp env))
              (eopl:error 'evaluar-expresion
                          "La condicion del if debe ser booleana"))))

      (let-exp (ids rands body)
        (let ((valores (evaluar-rands rands env)))
          (evaluar-expresion
           body
           (ambiente-extendido ids valores env)))))))


(provide (all-defined-out))




