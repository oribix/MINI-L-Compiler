all: mini_l.lex
	flex mini_l.lex && gcc -o lexer lex.yy.c -lfl

run: mini_l.lex
	flex mini_l.lex && gcc -o lexer lex.yy.c -lfl && ./test.sh

clean:
	rm -f lexer lex.yy.c

