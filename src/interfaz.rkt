#lang eopl
;Autores: Adriana Milena Noscue Dagua 2477336, Sebastian Cucalon Astorquiza 2477344
;Santiago Torres Rojas 2380301, Nicolle Camila Hoyos Puin 2380608

;; Taller 2 — El intérprete de Cauca.
;; El punto de entrada y el REPL. Requiere sintaxis.rkt e interprete.rkt.

(require "sintaxis.rkt")
(require "interprete.rkt")

;; interpretar : string -> valor
;; Analiza el texto de un programa con el parser y evalúa el árbol
;; resultante con evaluar-programa.

(define interpretar
  (lambda (texto)
    (evaluar-programa (parser texto))))


;; interpretador : -> void
;; REPL de Cauca, que se abre con (interpretador). Se construye con
;; sllgen:make-rep-loop sobre evaluar-programa y el parser de flujo que
;; da sllgen:make-stream-parser.

(define interpretador
  (lambda ()
    (sllgen:make-rep-loop
     "--> "
     evaluar-programa
     (sllgen:make-stream-parser
      especificacion-lexica
      especificacion-gramatical))))

(provide (all-defined-out))




; ==========================================
; PARTE 1: EJEMPLOS DE EJECUCION
; Ejecutar desde la consola de DrRacket
; ==========================================

; Ejemplo 1: numero
; (interpretar "25")
; Resultado esperado: 25

; Ejemplo 2: variable del ambiente inicial
; (interpretar "n")
; Resultado esperado: 10

; Ejemplo 3: booleano verdadero
; (interpretar "true")
; Resultado esperado: #t

; Ejemplo 4: booleano falso
; (interpretar "false")
; Resultado esperado: #f

; Ejemplo 5: primitivas aritmeticas
; (interpretar "+(-(8,3),*(2,3),/(8,2),add1(4),sub1(5))")
; Resultado esperado: 24

; Ejemplo 6: primitivas relacionales
; (interpretar "and(>(8,3),>=(3,3),<(2,5),<=(4,4),==(6,6))")
; Resultado esperado: #t

; Ejemplo 7: primitivas logicas
; (interpretar "or(not(false),and(true,false))")
; Resultado esperado: #t

; Ejemplo 8: condicional if
; (interpretar "if >(8,3) then 100 else 0 end")
; Resultado esperado: 100

; Ejemplo 9: variables locales con let
; (interpretar "let x = 5 y = 3 in +(x,y) end")
; Resultado esperado: 8

; Ejemplo 10: area de un rectangulo
; (interpretar "let base = 8 altura = 5 in if and(>(base,0),>(altura,0)) then *(base,altura) else 0 end end")
; Resultado esperado: 40


; ==========================================
; CASOS DE ERROR
; Ejecutar por separado desde la consola
; ==========================================

; Error 1: condicion no booleana
; (interpretar "if 5 then 10 else 20 end")

; Error 2: division por cero
; (interpretar "/(10,0)")

; Error 3: suma con un argumento no numerico
; (interpretar "+(2,true)")
