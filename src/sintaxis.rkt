#lang eopl
;Autores: Adriana Milena Noscue Dagua 2477336, Sebastian Cucalon Astorquiza 2477344
;Santiago Torres Rojas 2380301, Nicolle Camila Hoyos Puin 2380608

;; Taller 2 — El intérprete de Cauca.
;; Especificación léxica, especificación gramatical, scanner y parser.
;; Este módulo no requiere ningún otro.
;;
;; Lo que se escribe aquí:
;;
;;   especificacion-lexica      comentarios que empiezan con //, espacios
;;                              en blanco, números enteros y flotantes con
;;                              signo, e identificadores que empiezan por
;;                              letra y siguen con letras, dígitos, guion
;;                              bajo o signo de interrogación
;;   especificacion-gramatical  las producciones de <programa>,
;;                              <expresion> y <primitiva>, con los nombres
;;                              de constructor que indican los recuadros
;;                              del enunciado
;;   scanner : string -> lista de tokens   se construye con
;;                                         sllgen:make-string-scanner
;;   parser  : string -> programa          se construye con
;;                                         sllgen:make-string-parser
;;
;; La llamada a sllgen:make-define-datatypes genera los datatypes
;; programa, expresion y primitiva a partir de la gramática, con sus
;; constructores y sus predicados. Mientras la gramática esté vacía no
;; genera ninguno.


(define especificacion-lexica
  '(
    (espacio-blanco (whitespace) skip)
    (comentario ("//" (arbno (not #\newline))) skip)
    (identificador
     (letter (arbno (or letter digit "_" "?")))
     symbol)
    (numero
     (digit (arbno digit))
     number)
    (numero
     ("-" digit (arbno digit))
     number)
    (numero
     (digit (arbno digit) "." digit (arbno digit))
     number)
    (numero
     ("-" digit (arbno digit) "." digit (arbno digit))
     number)
    ))



(define especificacion-gramatical
  '(
    ;; Un programa contiene una expresion.
    (programa
     (expresion)
     a-program)

    ;; Literales numericos.
    (expresion
     (numero)
     lit-exp)

    ;; Variables.
    (expresion
     (identificador)
     var-exp)

    ;; Booleanos.
    (expresion
     ("true")
     true-exp)

    (expresion
     ("false")
     false-exp)

    ;; Aplicacion de primitivas.
    (expresion
     (primitiva "(" (separated-list expresion ",") ")")
     prim-exp)

    ;; Condicional.
    (expresion
     ("if" expresion
           "then" expresion
           "else" expresion
           "end")
     if-exp)

    ;; Ligaduras locales.
    (expresion
     ("let" (arbno identificador "=" expresion)
            "in" expresion
            "end")
     let-exp)


    ;; Primitivas aritmeticas
  

    (primitiva ("+") sum-prim)
    (primitiva ("-") minus-prim)
    (primitiva ("*") mult-prim)
    (primitiva ("/") div-prim)

    (primitiva ("add1") add-prim)
    (primitiva ("sub1") sub-prim)


   
    ;; Primitivas relacionales
   

    (primitiva (">") mayor-prim)
    (primitiva (">=") mayorigual-prim)
    (primitiva ("<") menor-prim)
    (primitiva ("<=") menorigual-prim)
    (primitiva ("==") igual-prim)



    ;; Primitivas logicas
   

    (primitiva ("not") not-prim)
    (primitiva ("and") and-prim)
    (primitiva ("or") or-prim)
    ))

(sllgen:make-define-datatypes especificacion-lexica especificacion-gramatical)


;; mostrar-datatypes : -> void
;; Lista en pantalla los datatypes que SLLGEN genera a partir de la
;; gramática. Sirve para revisar los nombres de los constructores.
(define mostrar-datatypes
  (lambda ()
    (sllgen:list-define-datatypes especificacion-lexica especificacion-gramatical)))

;; scanner : string -> lista de tokens
;; Convierte el texto en tokens usando SLLGEN.

(define scanner
  (sllgen:make-string-scanner
   especificacion-lexica
   especificacion-gramatical))



; ==========================================
; EJEMPLOS DEL SCANNER
; ==========================================

; Ejemplo 1: reconocer un numero
(scanner "25")

; Ejemplo 2: reconocer un identificador
(scanner "base")

; Ejemplo 3: reconocer una operacion aritmetica
(scanner "+(2,3)")

; Ejemplo 4: reconocer una expresion condicional
(scanner "if true then 10 else 20 end")

; Ejemplo 5: reconocer una declaracion let
(scanner "let x = 5 in +(x,3) end")



;; parser : string -> programa
;; Convierte el texto en un AST usando SLLGEN.

(define parser
  (sllgen:make-string-parser
   especificacion-lexica
   especificacion-gramatical))



; ==========================================
; EJEMPLOS DEL PARSER
; ==========================================

; Ejemplo 1: analizar un numero
(parser "25")

; Ejemplo 2: analizar una variable
(parser "base")

; Ejemplo 3: analizar una operacion aritmetica
(parser "+(2,3)")

; Ejemplo 4: analizar un condicional
(parser "if true then 10 else 20 end")

; Ejemplo 5: analizar una declaracion let
(parser "let x = 5 in +(x,3) end")






(provide (all-defined-out))






