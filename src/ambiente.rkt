#lang eopl
;Autores: Adriana Milena Noscue Dagua 2477336, Sebastian Cucalon Astorquiza 2477344
;Santiago Torres Rojas 2380301, Nicolle Camila Hoyos Puin 2380608

;; Taller 2 — El intérprete de Cauca.
;; El TAD ambiente, la búsqueda de ligaduras y el ambiente inicial.
;; Requiere sintaxis.rkt y valores.rkt.
;;
;; Aquí se declara con define-datatype el tipo ambiente, con tres
;; variantes:
;;
;;   ambiente-vacio()
;;   ambiente-extendido(ids, valores, env)
;;     ids      (list-of symbol?)
;;     valores  list?
;;     env      ambiente?
;;   ambiente-recursivo(proc-names, idss, bodies, env)
;;     proc-names  (list-of symbol?)   los nombres declarados en el letrec
;;     idss        list?               la lista de parámetros de cada uno
;;     bodies      (list-of expresion?) los cuerpos, guardados sin evaluar
;;     env         ambiente?
;;
;; La variante recursiva no construye clausuras: las arma apply-env en el
;; momento de la búsqueda, y el ambiente que les entrega es el propio
;; ambiente-recursivo (EOPL, sección 3.4, figura 3.9).

(require "sintaxis.rkt")
(require "valores.rkt")

;; apply-env : ambiente x symbol -> valor
;; Busca el identificador en el ambiente, respetando el shadowing de las
;; ligaduras más recientes, y levanta eopl:error si no está ligado.
; Definición del tipo de dato ambiente.

(define-datatype ambiente ambiente?
  (ambiente-vacio)
  (ambiente-extendido
   (ids (list-of symbol?))
   (valores list?)
   (env ambiente?))
  (ambiente-recursivo
   (proc-names (list-of symbol?))
   (idss list?)
   (bodies (list-of expresion?))
   (env ambiente?)))

;; Busca una variable en el ambiente.

(define apply-env
  (lambda (env id)
    (cases ambiente env
      (ambiente-vacio ()
        (eopl:error 'apply-env
                    "Variable no definida: ~s" id))

      (ambiente-extendido (ids valores ambiente-anterior)
        (let buscar ((ids-restantes ids)
                     (valores-restantes valores))
          (cond
            ((null? ids-restantes)
             (apply-env ambiente-anterior id))
            ((eqv? id (car ids-restantes))
             (car valores-restantes))
            (else
             (buscar (cdr ids-restantes)
                     (cdr valores-restantes))))))

      (ambiente-recursivo (proc-names idss bodies ambiente-anterior)
        (let buscar ((nombres-restantes proc-names)
                     (parametros-restantes idss)
                     (cuerpos-restantes bodies))
          (cond
            ((null? nombres-restantes)
             (apply-env ambiente-anterior id))
            ((eqv? id (car nombres-restantes))
             (cerradura (car parametros-restantes)
                        (car cuerpos-restantes)
                        env))
            (else
             (buscar (cdr nombres-restantes)
                     (cdr parametros-restantes)
                     (cdr cuerpos-restantes)))))))))

;; Ambiente inicial: n=10, m=3, p=7, q=2, r=5.
(define ambiente-inicial
  (lambda ()
    (ambiente-extendido
     '(n m p q r)
     '(10 3 7 2 5)
     (ambiente-vacio))))

(provide (all-defined-out))

