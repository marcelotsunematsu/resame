#!/usr/bin/python
# encoding: utf-8

# Este arquivo é chamado pelo make para executar todos os resolvedores e
# verificar se eles estão produzindo respostas corretas.

from same import *
import os
import sys
import subprocess
from time import time

LOG = "testes.log"

def is_executable(path):
    return os.path.isfile(path) and os.access(path, os.X_OK)

def listar_dir(dir):
    arquivos = []
    for dirpath, _, files in os.walk(dir):
        for f in files:
            f = os.path.join(dirpath, f)
            arquivos.append(f)
    arquivos.sort()
    return arquivos

def find_runs(path):
    if os.path.isdir(path):
        r = []
        for f in os.listdir(path):
            pathf = os.path.join(path, f)
            if f.startswith("run-") and is_executable(pathf):
                r.append(pathf)
        return r
    else:
        []

def encontrar_resolvedores(path):
    resolvedores = []
    for f in os.listdir(path):
        nome = f
        f = os.path.join(path, f)
        runs = find_runs(f)
        build = os.path.join(f, 'build')
        if runs:
            if not is_executable(build):
                build = None
            resolvedores.append((nome, build, runs))
    resolvedores.sort()
    return resolvedores

def executar_resolvedores(log, resolvedores, casos):
    total = len(casos)
    for nome, build, runs in resolvedores:
        if build:
            print "Executando %s" % (build,)
            if not exec_prog(build):
                print "Falha no make. Ignorando %s" % (nome,)
                continue                
        for run in runs:
            inicio = time()
            acertos = 0
            for caso in casos:
                if executar_resolvedor_caso(log, nome, run, caso):
                    acertos += 1
            tempo = time() - inicio
            print "%d/%d acertos (%.2f s)" % (acertos, total, tempo)
            log.write("%d/%d acertos (%.2f)\n" % (acertos, total, tempo))

def exec_prog(prog):
    try:
        retcode = subprocess.call(prog, shell=True)
        if retcode < 0:
            return False
    except OSError as e:
        print >> sys.stderr, e
        return False
    return True

def executar_resolvedor_caso(log, nome, resolvedor, caso):
    print resolvedor, caso,
    sys.stdout.flush()
    log.write('%s %s ' % (resolvedor, caso))

    tem_solucao = 'sem-solucao' not in caso
    jogo = string_to_jogo(open(caso).read())

    ok, resolucao = executar_programa(resolvedor, os.path.abspath(caso))
    if not ok:
        print 'Fail (veja o arquivo %s)' % (LOG)
        log.write('Fail\n')
        log.write('  %s\n' % (resolucao))
        return False

    erros = checar_resolucao(jogo, resolucao, tem_solucao)
    if not erros:
        print 'OK'
        log.write('OK\n')
    else:
        print 'Fail (veja o arquivo %s)' % (LOG)
        log.write('Fail\n')
        log.write('  Resolucao\n')
        for s in resolucao:
            log.write('  %s\n' % (s))
        for s in erros:
            log.write('  %s\n' % (s))
    log.flush()
    return not erros

def executar_programa(prog, caso):
    try:
        # TODO: desviar stderr para o arquivo de log
        return True, subprocess.check_output([prog, caso]).split('\n')
    except Exception as e:
        return False, e

def main():
    if len(sys.argv) != 3:
        print "Numero de parametros incorreto."
        print "Modo de usar: %s diretorio-com-os-resolvedores diretorio-com-os-testes" % (sys.argv[0])
        sys.exit(1)

    resolvedores = encontrar_resolvedores(sys.argv[1])    
    if len(resolvedores) == 0:
        print "Nenhum resolvedor encontrado em %s" % (sys.argv[1])
        sys.exit(1)

    casos = listar_dir(sys.argv[2])
    if len(casos) == 0:
        print "Nenhum caso de teste encontrado em %s" % (sys.argv[2])
        sys.exit(1)

    with open(LOG, 'w') as log:
        executar_resolvedores(log, resolvedores, casos)

if __name__ == '__main__':
    main()
