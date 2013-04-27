#lang racket
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


(define test-suite-resameunits
  (test-suite
   "Resame Units"
   (criar-grupo)
   (remover-grupo)
   (infra)))

(define (criar-grupo)
  (test-suite 
   "Criar Grupo"
   (test-case
    "Ler jogo"
   (check-equal? (ler-jogo "/home/fabricio/resame/testes/alguns/com-solucao/3-3-3")
              '(("1" "1" "1") ("3" "3" "2") ("2" "1" "2"))))
      
   (test-case
    "filtra-vizinhos com posição valida"
   (check-equal? (filtra-vizinhos p12 '() same) (list (position 1 1))))  
   
   (test-case
    "filtra-vizinhos com posições invalidas"
   (check-equal? (filtra-vizinhos p12 '() same) (list (position 1 1))))  
   
   (test-case
   "posicao-valida com posicao invalida -1 0"
   (check-equal? (posicao-valida (position -1 0) same) #f))

   (test-case
   "posicao-valida com posicao invalida 0 -1"
   (check-equal? (posicao-valida (position 0 -1) same) #f))

   (test-case
   "posicao-valida com posicao invalida -1 -1"
   (check-equal? (posicao-valida (position -1 -1) same) #f))

   (test-case
   "posicao-valida com posicao invalida 3 3"
   (check-equal? (posicao-valida (position 3 3) same) #f))

   (test-case
   "posicao-valida com posicao invalida 2 3"
   (check-equal? (posicao-valida (position 2 3) same) #t))

   (test-case
   "grupo-flood"
   (check-equal? (sort (grupo-flood same '() (list p12)) position<?) (list (position 0 0) 
                                                                              (position 1 0)
                                                                              (position 1 1)
                                                                              (position 1 2)
                                                                              (position 2 0))))
   
   )
  )

(define (remover-grupo)
  (test-suite 
   "Remover Grupo"    
      
   (test-case
    "Remove grupo"
   (check-equal? (remove-grupo same group12) 
                  ;esperado
                 '((3 1) (3 3) (1 3 1))))
   
   (test-case
    "Remove elemento do grupo '((0 0)(1 0)(1 1)(1 2)(2 0)) da coluna '(2 2 2) 0"
    (check-equal? (remove-elemento-coluna 0 '(2 2 2) group12)
                  ;esperado
                  #f))
   
   (test-case
    "Remove elemento do grupo da coluna '((0 0)(1 0)(1 1)(1 2)(2 0)) da coluna '(3 2 1) 1"
    (check-equal? (remove-elemento-coluna 1 '(3 2 1) group12)
                  ;esperado
                  '(3 1)))
   
   
   (test-case    
    "Remove grupo valido"
   (check-equal? (sequence*->list* (same-remove-group same group12))
                  ;esperado
                  '((3 1) (3 3) (1 3 1))))
   
   ))

(define (infra)
  (test-case
    "arquivo->jogo"
    (check-equal? (arquivo->jogo same "/home/fabricio/resame/testes/alguns/com-solucao/3-3-3") 
                  '((1 1 1) (3 3 2) (2 1 2)))))



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

(define (run-tests-resame)
  (run-tests test-suite-resameunits)
  (void))

(run-tests-resame)