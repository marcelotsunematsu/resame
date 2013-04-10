#!/usr/bin/python
# encoding: utf-8

# Este arquivo contém todas as funções utilizadas por testador.py para
# verificar se uma resolução está correta.
#
# Você pode implementar os seus resolvedores utilizando as ideias e algoritmos
# deste arquivo.
#
# Os testes estão no formato utilizado pelo doctest. Veja
# http://docs.python.org/library/doctest.html

import sys
from collections import defaultdict, deque

COR_NULA = 0

def checar_resolucao(jogo, resolucao, tem_solucao):
    """
    Entrada: um jogo, uma resolucao para o jogo (veja a funcao
    parse_resolucao), e um valor booleano indicando se o jogo tem solucao ou nao
    Saida: uma lista de erros da resolucao ou vazio se a resolucao estiver correta    
    """
    # TODO: criar testes automaticos para esta funcao
    erros = []
    try:
        reso = parse_resolucao(resolucao)
    except Exception as e:
        erros.append("Erro na formatacao da resolucao. Verifique a especificacao do trabalho.")
        erros.append("Resolucao obtida")
        erros.extend(resolucao)
        erros.append("Erro encontrado: " + str(e))
        return erros

    if not tem_solucao:
        if reso:
            erros.append("A resolucao deveria ser sem-solucao, mais foi")
            erros.extend(resolucao)
        return erros
    
    colunas, linhas = len(jogo), len(jogo[0])
    j = 1
    for jogada, resultado in reso:
        try:
            jogo = remover_grupo(jogo, *jogada)
        except Exception as e:
            erros.append('Erro na jogada %d (%d, %d)' % (j, jogada[0], jogada[1]))
            erros.append(str(e))
            return erros
        if resultado != jogo_to_string(jogo, linhas, colunas):
            erros.append('Erro apos a jogada %d (%d, %d)' % (j, jogada[0], jogada[1]))
            erros.append('Esperado')
            erros.extend(jogo_to_string(jogo, linhas, colunas).split('\n'))
            erros.append('Obtido')
            erros.extend(resultado.split('\n'))
            return erros
        j += 1

    if not concluido(jogo):
        erros.append("As jogadas acabaram e restaram posicoes coloridas")
        erros.append("Resolucao obtida")
        erros.extend(resolucao)
    
    return erros

def remover_grupo(jogo, lin, col):
    """
    Entrada: uma lista de colunas do jogo same, e uma posicao (linha, coluna)
    Saida: uma lista de colunas do jogo com o grupo da (linha, coluna) removido
    Excecoes: Se a posicao e invalida ou se o tamanho do grupo e 1
    Exemplo:
    Considerando o seguinde jogo
    2 | 2 1 3 1
    1 | 2 2 2 3
    0 | 2 3 3 1
    --+---------
      | 0 1 2 3
    Remover o grupo em (1, 2) gera o jogo
    2 | 0 0 1 0
    1 | 1 3 3 0
    0 | 3 3 1 0
    --+---------
      | 0 1 2 3
    >>> remover_grupo([[2, 2, 2], [3, 2, 1], [3, 2, 3], [1, 3, 1]], 1, 2)
    [[3, 1], [3, 3], [1, 3, 1]]
    >>> remover_grupo([[2, 2, 2], [3, 2, 1], [3, 2, 3], [1, 3, 1]], 2, 4)
    Traceback (most recent call last):
      ...
    Exception: Posicao invalida 2, 4
    >>> remover_grupo([[2, 2, 2], [3, 2, 1], [3, 2, 3], [1, 3, 1]], 0, 3)
    Traceback (most recent call last):
      ...
    Exception: Selecionado um grupo de tamanho 1 em 0, 3
    """
    if not posicao_valida(jogo, lin, col) or jogo[col][lin] == COR_NULA:
        raise Exception("Posicao invalida %d, %d" % (lin, col))

    grupo = criar_grupo(jogo, lin, col)

    if len(grupo) == 1:
        raise Exception("Selecionado um grupo de tamanho 1 em %d, %d" % (lin, col))

    novo_jogo = []
    nova_coluna = []
    for col in xrange(len(jogo)):
        for lin in xrange(len(jogo[col])):
            if (lin, col) not in grupo:
                nova_coluna.append(jogo[col][lin])
        if nova_coluna:
            novo_jogo.append(nova_coluna)
            nova_coluna = []
    return novo_jogo

def criar_grupo(jogo, lin, col):
    """
    Entrada: uma lista de colunas do jogo same, e uma posicao (linha, coluna)
    Saida: uma lista das posicoes (par de inteiros) que podem ser agrupadas com
    o elemento na posicao (lin, col)
    Exemplo:
    Considerando o seguinde jogo
    2 | 2 1 3 1
    1 | 2 2 2 3
    0 | 2 3 3 1
    --+---------
      | 0 1 2 3
    Temos que o grupo para
         (1, 1) e (0, 0), (1, 0), (1, 1), (1, 2), (2, 0)
         (0, 1) e (0, 1), (0, 2)
         (2, 2) e (2, 2)
    >>> jogo = [[2, 2, 2], [3, 2, 1], [3, 2, 3], [1, 3, 1]]
    >>> sorted(criar_grupo(jogo, 1, 1))
    [(0, 0), (1, 0), (1, 1), (1, 2), (2, 0)]
    >>> sorted(criar_grupo(jogo, 0, 1))
    [(0, 1), (0, 2)]
    >>> sorted(criar_grupo(jogo, 2, 2))
    [(2, 2)]
    """
    grupo = []
    cor = jogo[col][lin]
    candidados = deque([(lin, col)])
    while candidados:
        lin, col = candidados.popleft()
        if posicao_valida(jogo, lin, col) and (lin, col) not in grupo and jogo[col][lin] == cor:
             grupo.append((lin, col))
             candidados.extend(vizinhos(lin, col))
    return grupo

def vizinhos(lin, col):
    return [(lin - 1, col), (lin, col - 1), (lin, col + 1), (lin + 1, col)]

def concluido(jogo):
    return len(jogo) == 0

def posicao_valida(jogo, lin, col):
    return 0 <= col < len(jogo) and 0 <= lin < len(jogo[col])

def parse_ints(s):
    """
    Entrada: uma string de inteiros separados por espaco
    Saida: uma lista de inteiros
    >>> parse_ints("  1 3 5  2 ")
    [1, 3, 5, 2]
    """
    return map(int, s.strip().split())

def string_to_jogo(s):
    """
    Entrada: uma string que representa um jogo same
    Saida: uma lista com as colunas do jogo
    >>> s = '''2 1 3 1
    ...        2 2 2 3
    ...        2 3 3 1'''
    >>> string_to_jogo(s)
    [[2, 2, 2], [3, 2, 1], [3, 2, 3], [1, 3, 1]]
    """
    m = map(parse_ints, s.strip().split('\n'))
    linhas, colunas = len(m), len(m[0])
    jogo = []
    for col in xrange(colunas):
        coluna = []
        for lin in xrange(linhas):
            cor = m[linhas - lin - 1][col]
            coluna.append(cor)
        jogo.append(coluna)
    return jogo

def jogo_to_string(jogo, linhas, colunas):
    """
    Entrada: uma lista de colunas do jogo same, numero de linhas e numero de colunas
    Saida: uma string que representa o jogo
    >>> print jogo_to_string([[2, 2, 2], [3, 2, 1], [3, 2, 3], [1, 3, 1]], 3, 4)
    2 1 3 1
    2 2 2 3
    2 3 3 1
    """
    m = [[COR_NULA] * colunas for lin in xrange(linhas)]
    for col in xrange(len(jogo)):
        for lin in xrange(len(jogo[col])):
            m[linhas - lin - 1][col] = jogo[col][lin]
    return "\n".join([" ".join(map(str, linha)) for linha in m])

def parse_resolucao(linhas):
    """
    Entrada: um lista de linhas (strings) da forma: jogada (par de inteiros),
    linha em branco, resultado (matriz do jogo), linha em branco.
    Saida: uma lista de pares (jogada, resultado), onde jogada é uma 2-tupla de
    inteiros e resultado e a string que representa o jogo.
    >>> s = '''3 4
    ...
    ... 0 0 1 0
    ... 1 3 3 0
    ... 3 3 1 0
    ... 
    ... 1 1
    ...
    ... 0 0 0 0
    ... 0 1 0 0
    ... 1 1 0 0
    ...
    ... 1 1
    ... 
    ... 0 0 0 0
    ... 0 0 0 0
    ... 0 0 0 0'''
    >>> parse_resolucao(s.split('\\n'))
    [((3, 4), '0 0 1 0\\n1 3 3 0\\n3 3 1 0'), ((1, 1), '0 0 0 0\\n0 1 0 0\\n1 1 0 0'), ((1, 1), '0 0 0 0\\n0 0 0 0\\n0 0 0 0')]
    """
    linhas = map(lambda l: l.strip(), linhas)
    if linhas[0] == 'sem-solucao':
        return []
    resolucao = []
    i = 0
    while i < len(linhas) and linhas[i] == '':
        i += 1
    while i < len(linhas):
        jogada = tuple(parse_ints(linhas[i]))
        i += 1
        # pula as linhas em branco
        while i < len(linhas) and linhas[i] == '':
            i += 1
        resultado = []
        while i < len(linhas) and linhas[i] != '':
            resultado.append(linhas[i])
            i += 1
        # pula as linhas em branco
        while i < len(linhas) and linhas[i] == '':
            i += 1
        resolucao.append((jogada, '\n'.join(resultado)))
    return resolucao
