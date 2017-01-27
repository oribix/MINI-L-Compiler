all: CS152LexAnalyzerGen.lex
	flex CS152LexAnalyzerGen.lex && gcc lex.yy.c -lfl

run: CS152LexAnalyzerGen.lex
	flex CS152LexAnalyzerGen.lex && gcc lex.yy.c -lfl && ./a.out test1.min


clean:
	rm -f ./a.out lex.yy.c

