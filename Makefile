all: bison lexer

run: all
	./test.sh

lexer: flex
	gcc -o lexer lex.yy.c -lfl

flex: mini_l.lex
	flex mini_l.lex

bison: mini_l.y
	bison -d -v --name-prefix=y mini_l.y

clean:
	rm -f lexer lex.yy.c mini_l.output mini_l.tab.*

