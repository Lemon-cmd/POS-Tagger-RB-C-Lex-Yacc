lex pos.l
yacc -d pos.y
cc -c lex.yy.c y.tab.c
cc -o work lex.yy.o y.tab.o -ll
