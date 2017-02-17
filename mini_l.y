


//Prologue (types and variables in in actions - header files, 
//declare yylex, yyerror, any other global indentification used by actions

%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
%}

//Bison Declartions
//1) names of termianls
//2) names of non-terminals
//3) describe operation procedures
//4) data type of sematic values of vairous symboles



%function
%beginparams
%endparams
%beginlocals
%endlocals
%beginbody
%endbody
%integer
%array
%of
%if
%then
%endif
%else
%while
%do
%beginloop
%endloop
%continue
%read
%write
%and
%or
%not
%true
%false		




%union{
  int		int_val;
  string*	op_val;
}

%start	input 

%token	<int_val>	INTEGER_LITERAL
%type	<int_val>	exp
%left	PLUS
%left	MULT

//grammer rules - how to construct each nontermiasnl symblo from its parts

%%

input:		/* empty */
		| exp	{ cout << "Result: " << $1 << endl; }
		;

exp:		INTEGER_LITERAL	{ $$ = $1; }
		| exp PLUS exp	{ $$ = $1 + $3; }
		| exp MULT exp	{ $$ = $1 * $3; }
		;

//Mult-OP ->  * | / | %

Mult-OP:	INTEGER_LITERAL	{ $$ = $1; }
		| term MULT term { $$ = $1 * $3; }
		| term DIV term	{ $$ = $1 / $3; }
		| term PERC term { $$ = $1 % $3; }
		;



%%

//epilogue - declation of function declared in prologue

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}


