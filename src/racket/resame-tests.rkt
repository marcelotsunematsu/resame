#lang racket

; Veja o arquivo resame.rkt para a descrição do que cada função deve fazer.
;
; Você não deve editar este arquivo.


(require rackunit/text-ui rackunit "resame.rkt")

(define same '((2 2 2) (3 2 1) (3 2 3) (1 3 1)))

(define p12 (position 1 2))

; grupo que deve ser criado se a posição 1 2 de same for selecionada
(define group12 (list (position 0 0)
                      (position 1 0) (position 1 1) (position 1 2)
                      (position 2 0)))

(define p02 (position 0 2))

; grupo que deve ser criado se a posição 0 2 de same for selecionada
(define group02 (list (position 0 1) (position 0 2)))

;; Início dos testes
(define test-suite-resame
  (test-suite
   "Resame"
   (test-suite-same-create-group "basic" same-create-group-basic)
   (test-suite-same-remove-group "basic" same-remove-group-basic)
   (test-suite-same-create-group "fast" same-create-group-fast)
   (test-suite-same-remove-group "fast" same-remove-group-fast)))

(define (test-suite-same-create-group mode same-create-group)
  (test-suite
   (string-append "Função criar grupo - " mode)
   (test-case
    "Caso 1"
    ; Os elementos da lista retornada pela função same-create-group podem
    ; estar em qualquer ordem, desta forma, é necessário ordenar o grupo
    ; criado para fazer a comparação com o grupo esperado.
    (check-equal? (sort (same-create-group same p12) position<?)
                  ;esperado
                  group12))
   (test-case
    "Caso 2"
    (check-equal? (sort (same-create-group same p02) position<?)
                  ;esperado
                  group02))))

(define (test-suite-same-remove-group mode same-remove-group)
  (test-suite
   (string-append "Função remover grupo - " mode)
   (test-case
    "Caso 1"
    ; Como este teste é usado para as funções
    ; same-create-group-basic e same-create-group-fast
    ; é necessário converter a resposta para uma lista para fazer
    ; a comparação com o resultado esperado.
    (check-equal? (sequence*->list* (same-remove-group same group12))
                  ;esperado
                  '((3 1) (3 3) (1 3 1))))
   (test-case
    "Caso 2"
    (check-equal? (sequence*->list* (same-remove-group same group02))
                  ;esperado
                  '((2 2 2) (2 1) (2 3) (1 3 1))))
   ))

; Funções auxiliares
(define (position<? p1 p2)
  (define p1-lin (position-lin p1))
  (define p1-col (position-col p1))
  (define p2-lin (position-lin p2))
  (define p2-col (position-col p2))
  (if (= p1-lin p2-lin)
      (< p1-col p2-col)
      (< p1-lin p2-lin)))

(define (sequence*->list* a)
  (if (vector? a)
      (for/list ([e a])
        (sequence*->list* e))
      a))

; Chamada principal
(define (run-tests-resame)
  (run-tests test-suite-resame)
  (void))

(run-tests-resame)