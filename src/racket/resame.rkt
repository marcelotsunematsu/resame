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

; Provide para testes unitários
(provide cor
         vizinhos
         remove-linha
         remove-coluna
         vizinhos
         grupo-flood
         ler-jogo
         filtra-vizinhos
         posicao-valida
         arquivo->jogo
         same-remove-group
         remove-posicao
         cabeca-col
         corpo-col-filtrado
         calda-col
         )


(define (cor same p)
  (list-ref (list-ref same (position-col p))
            (position-lin p)))

(define (remove-linha same group lin col)
  '())
         
(define (remove-coluna same group col)
  (remove-linha same group 0 col))

;excluir os vizinhos de cor diferente
(define (vizinhos p)
  (let* ([cima (position (add1 (position-lin p))
                           (position-col p))]
         [baixo (position (sub1 (position-lin p))
                           (position-col p))]
         [esquerda (position (position-lin p)
                           (sub1 (position-col p)))]
         [direita (position (position-lin p)
                           (add1 (position-col p)))])
    (list cima baixo esquerda direita)))


(define (posicao-valida p same)
  (and (>= (position-lin p) 0)
       (>= (position-col p) 0)
       (< (position-col p) (length same))
       (< (position-lin p) (length (car same)))
  ))

(define (filtra-vizinhos p acumulador same)
  (filter (lambda (c) 
            (and (posicao-valida c same) 
                 (not (member c acumulador))
                 (equal? (cor same c) (cor same p)))) 
          (vizinhos p)))
  
(define (grupo-flood same acumulador fronteira)
  (if (null? fronteira)
      acumulador
      (let ([vizinhos-atual (filtra-vizinhos (first fronteira) acumulador same)])
         (grupo-flood same (append acumulador vizinhos-atual) (append (rest fronteira) vizinhos-atual)))))

(define (resolver-linha jogo lin col)
  '())

(define (resolver-coluna jogo col)
  (resolver-linha jogo 0 col))

(define (resolver jogo)
  (resolver-coluna jogo 0))

; ----------------------------------------------------------------------
; Esta função recebe como parâmetro um jogo same e retorna uma lista de
; posições que quando clicadas resolvem o jogo. Se o jogo não tem solução, está
; função retornar #f.
; Lembre-se que deve ser criado um stream de possíveis grupos (sem repetição)
; que será processado por esta função.
; Esta função não é testada no arquivo resame-tests.rkt.
; Esta função é testada pelo testador externo.
(define (same-solve-basic same)
  #f)

(define (same-solve-fast same)
  #f)

; Esta função recebe como parâmetro um jogo same e uma posição p e criar um
; grupo (lista de posições) que contém p.
(define (same-create-group-basic same p)
  (let ([grupo (grupo-flood same '() (list p))])
    (if (empty? grupo) 
        #f
        grupo))
  )

(define (same-create-group-fast same p)
  '())

;; Definições para remoção de grupo

(define (remover-indice indice lista)
  (let ([cabeca (if (> indice 0)
                    (take lista indice)
                    #f)]
        [calda (if (> (+ indice 2) (length lista))
                   #f
                   (take-right lista (- (length lista) indice 1)))])        
    (cond [(and (not cabeca) (not calda)) #f]
          [(not cabeca) calda]
          [(not calda) cabeca]
          [else (append cabeca calda)]))
  )
  
(define (cabeca-col posicao same)
  (if (<= (position-col posicao) 0)
      #f
      (take same (position-col posicao))))

(define (corpo-col-filtrado posicao same)
  (remover-indice (position-lin posicao) (list-ref same (position-col posicao))))

(define (calda-col posicao same)
    (if (>= (+ (position-col posicao) 1) (length same))
      #f
      (take-right same (- (length same) (+ (position-col posicao)1)))))

(define (remove-posicao posicao same) 
  (let ([cabeca (cabeca-col posicao same)]
        [corpo (corpo-col-filtrado posicao same)]
        [calda (calda-col posicao same)])
    (cond 
      [(and cabeca (not calda)) (append cabeca corpo)]
      [(and (not cabeca) calda) (append corpo calda)]
      [(and (not cabeca) (not calda)) corpo]
      [(and cabeca calda (append cabeca corpo calda))])))
        

; Esta função recebe como parâmetro um jogo same e um grupo (lista de posições)
; e cria um novo jogo removendo as posições no grupo.
(define (same-remove-group same group)
  '())


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

;; Extras

(define (ler-jogo arquivo)
  (read-matrix (open-input-file arquivo)))

(define (arquivo->jogo arquivo)
  (apply string->number (car (ler-jogo arquivo))))
