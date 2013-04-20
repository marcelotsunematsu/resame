#lang racket

(provide position
         position-lin
         position-col
         same-create-group-basic
         same-remove-group-basic
         same-solve-basic
         same-create-group-fast         
         same-remove-group-fast         
         same-solve-fast
         main)

; Um Jogo same é representado por uma sequência de colunas, sem os elementos
; nulos (zeros).
;
; Por exemplo, o jogo (3 linhas x 4 colunas)
; 2 | 3 0 0 0
; 1 | 2 2 2 0
; 0 | 2 3 3 1
; --+--------
;   | 0 1 2 3
;
; pode ser representado por:
; 1 - uma lista de listas '((2 2 3) (3 2) (3 2) (1))
; 2 - um vetor de vetores #(#(2 2 3) #(3 2) #(3 2) #(1))
;
; Conforme a descrição do trabalho, deve ser implementado
; um resolvedor para cada representação. Por este motivo,
; existe a declaração de duas versões para cada função.
;
; Uma posição é representada pela estrutura position. Ex:
; > (define p (position 1 3)) ; linha 1 coluna 3
; > (position-lin p)          ; acessa o valor da linha de p
; 1
; > (position-col p)          ; acessa o valor da coluna de p
; 3


; Esta função recebe como parâmetro um jogo same e retorna uma lista de
; posições que quando clicadas resolvem o jogo. Se o jogo não tem solução, está
; função retornar #f.
; Lembre-se que deve ser criado um stream de possíveis grupos (sem repetição)
; que será processado por esta função.
; Esta função não é testada no arquivo resame-tests.rkt.
; Esta função é testada pelo testador externo.
(define (same-solve-basic same)
  '())

(define (same-solve-fast same)
  '())

; Esta função recebe como parâmetro um jogo same e uma posição p e criar um
; grupo (lista de posições) que contém p.
(define (same-create-group-basic same p)
  '())

(define (same-create-group-fast same p)
  '())

; Esta função recebe como parâmetro um jogo same e um grupo (lista de posições)
; e cria um novo jogo removendo as posições no grupo.
(define (same-remove-group-basic same group)
  '())

(define (same-remove-group-fast same p)
  #())

; Esta é a função principal. Ela é chamada pelo arquivo resame-main.rkt que
; passa como parâmetro o modo de resolução ("basico" ou "fast") e
; o nome do arquivo do jogo.  Esta função deve ler o jogo do arquivo, resolver
; utilizando o modo de resolução especificado e imprimir a resolução.
(define (main mode file)
  (printf "parametros ~a ~a\n" mode file))

;; struct postion
(struct position (lin col) #:transparent)

;; Algumas funções que você pode achar útil
(define (string-split s)
  (regexp-split #px"\\s+" s))

(define (read-matrix port)
  (reverse
   (for/list ([line (in-lines port)])
     (string-split line))))

(define (write-matrix matrix port)
  (for ([line (reverse matrix)])
    (printf "~a\n" (string-join line " "))))

(define (matrix-transpose lst)
  (if (or (empty? lst) (empty? (first lst)))
      empty
      (cons (map first lst)
            (matrix-transpose (map rest lst)))))
