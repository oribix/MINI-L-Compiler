


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



%token FUNCTION
%token BEGINPARAMS
%token ENDPARAMS
%token BEGINLOCALS
%token ENDLOCALS
%token BEGINBODY
%token ENDBODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token BEGINLOOP
%token ENDLOOP
%token CONTINUE
%token READ
%token WRITE
%token AND
%token OR
%token NOT
%token TRUE
%token FALSE

==
<>
<=
>=
<
>
;
:
,
(
)
[
]
:=
-
+
*
/
%



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

  /*
  input:	//empty	
  		| exp	{ cout << "Result: " << $1 << endl; }
  		;

  exp:		INTEGER_LITERAL	{ $$ = $1; }
  		| exp PLUS exp	{ $$ = $1 + $3; }
  		| exp MULT exp	{ $$ = $1 * $3; }
  		;
  */

Program : Function Program | epsilon

Function : function identifier ;
  beginparams Dec-Loop endparams
  beginlocals Dec-Loop endlocals
  beginbody Statement ; Statment-Loop endbody

Dec-Loop : Declaraion ; Dec-Loop | espilon

Statement-Loop : Statement ; Statement-Loop'

Statement-Loop' : Statement ; Statement-Loop' | epsilon



Declaration : identifier Identifier-Loop : Declaration' integer

Declaration' : array [ number ] of | epsilon

Identifier-Loop : , identifier Identifier-Loop | epsilon



Statement : Assignment | If-Statement | While-Loop | Do-While | read Var-Loop |
  write Var-Loop | continue | return Expression


Assignment: Var := Expression


If-Statement : if Bool-Expr then Statement-Loop Opt-Else endif

Opt-Else : else Statement-Loop | epsilon


While-Loop : while Bool-Expr beginloop Statement-Loop endloop


Do-While : do beginloop Statement-Loop endloop while Bool-Expr


Var-Loop : Var Var-Loop'

Var-Loop' : , Var Var-Loop' | epsilon



Bool-Expr : Relation-And-Expr Bool-Expr'

Bool-Expr' : or Relation-And-Expr Bool-Expr' | epsilon



Relation-And-Expr : Relation-Expr Relation-And-Expr'

Relation-And-Expr' : and Relation-Expr Relation-And-Expr' | epsilon



Relation-Expr : Opt-Not Relation-Expr'

Relation-Expr' : Expression Comp Expression | true | false | ( Bool-Expr )


Opt-Not : not | epsilon



Comp : == | <> | < | > | <= | >=



Expression : Multiplicative-Expr Expression'

Expression' : PM-OP Multiplicative-Expr Expression' | epsilon

PM-OP : + | -


Multiplicative-Expr : Term Term-Loop

Term-Loop : Mult-OP term Term-Loop | epsilon

Mult-OP : * | / | %



Term : Opt-Minus Term' | identifier ( Term'' )

Term' : Var | number | ( Expression )

Term'': Expression-Loop | epsilon

Opt-Minus : - | epsilon

Expression-Loop : Expression Expression-Loop' | epsilon

Expression-Loop' : , Expression Expression-Loop | epsilon



Var : identifier Var'

Var' : [ Expression ] | epsilon



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


