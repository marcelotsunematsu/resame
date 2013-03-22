#lang racket

; Você não deve editar este arquivo.
; Este arquivo é executado pelo testador.

(require "resame.rkt")

(define args (current-command-line-arguments))

(main (vector-ref args 0)
      (vector-ref args 1))