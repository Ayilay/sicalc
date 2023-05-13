# This Makefile is designed to be simple and readable.  It does not
# aim at portability.  It requires GNU Make.

BASE = sicalc
BISON = bison
CC = gcc
INC = sipref.h calc.h

all: $(BASE)

lex.yy.c: $(BASE).l $(INC)
	flex $(BASE).l

%.c: %.y %.l
	$(BISON) $(BISONFLAGS) -t -d -o $*.c $<

%: %.c lex.yy.c sipref.c
	$(CC) $(CFLAGS)-o $@ $^ -lm

run: $(BASE)
	@echo "Type arithmetic expressions.  Quit with ctrl-d."
	./$<

clean:
	rm -f $(BASE) $(BASE).c $(BASE).html $(BASE).xml $(BASE).gv $(BASE).output lex.yy.c
