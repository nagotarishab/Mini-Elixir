# Makefile for Elixir Compiler (Phase 2)
# Usage:
#   make          - build the compiler
#   make test     - run both test cases
#   make clean    - remove generated files

CC = gcc
CFLAGS = -Wall -g

all: elixir_compiler

elixir_compiler: elixir.tab.c elixir.tab.h lex.yy.c
	$(CC) $(CFLAGS) -o elixir_compiler elixir.tab.c lex.yy.c -lfl

elixir.tab.c elixir.tab.h: elixir.y
	bison -d elixir.y

lex.yy.c: elixir.l elixir.tab.h
	flex elixir.l

test: elixir_compiler
	@echo ""
	@echo "========================================"
	@echo "  TEST CASE 1: Valid Input Program"
	@echo "========================================"
	./elixir_compiler < test_valid.elx

	@echo ""
	@echo "========================================"
	@echo "  TEST CASE 2: Input with Errors"
	@echo "========================================"
	./elixir_compiler < test_error.elx || true

clean:
	rm -f elixir_compiler elixir.tab.c elixir.tab.h lex.yy.c *.o
