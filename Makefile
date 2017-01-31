all: CS152LexAnalyzerGen.lex
	flex CS152LexAnalyzerGen.lex && gcc lex.yy.c -lfl

run: CS152LexAnalyzerGen.lex
	flex CS152LexAnalyzerGen.lex && gcc lex.yy.c -lfl && ./test.sh


clean:
	rm -f ./a.out lex.yy.c

