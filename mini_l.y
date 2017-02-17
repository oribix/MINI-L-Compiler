


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

%start  input 

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
%left AND
%left OR
%right NOT
%token TRUE
%token FALSE

%token EQ
%left NEG
%left LTE
%left GTE
%left LT
%left GT

%token SEMICOLON
%token COLON
%token COMMA

%left L_PAREN R_PAREN
%left L_SQUARE_BRACKET R_SQUARE_BRACKET

%right ASSIGN

%right SUB

%left ADD
%left MULT
%left DIV
%left MOD

%union{
  int value;
  char * string;
}


//grammer rules - how to construct each nontermiasnl symblo from its parts

%%

Program : Function Program | /* epsilon */;
;

Function : FUNCTION IDENTIFIER SEMICOLON
  BEGINPARAMS DecLoop ENDPARAMS
  BEGINLOCALS DecLoop ENDLOCALS
  BEGINBODY Statement SEMICOLON StatmentLoop ENDBODY
;

DecLoop : Declaration SEMICOLON DecLoop | /* epsilon */
;

StatementLoop : Statement SEMICOLON StatementLoop_
;

StatementLoop_ : Statement SEMICOLON StatementLoop_ | /* epsilon */
;



Declaration : IDENTIFIER IdentifierLoop : Declaration_ INTEGER
;

Declaration_ : ARRAY [ NUMBER ] OF | /* epsilon */
;

IdentifierLoop : , IDENTIFIER IdentifierLoop | /* epsilon */
;



Statement : Assignment | IfStatement | WhileLoop | DoWhile | READ VarLoop |
  WRITE VarLoop | CONTINUE | RETURN Expression
;


Assignment : Var := Expression


IfStatement : IF BoolExpr THEN StatementLoop OptElse ENDIF
;

OptElse : ELSE StatementLoop | /* epsilon */
;


WhileLoop : WHILE BoolExpr BEGINLOOP StatementLoop ENDLOOP
;


DoWhile : DO BEGINLOOP StatementLoop ENDLOOP WHILE BoolExpr
;


VarLoop : Var VarLoop_
;

VarLoop_ : , Var VarLoop_ | /* epsilon */
;



BoolExpr : RelationAndExpr BoolExpr_
;

BoolExpr_ : OR RelationAndExpr BoolExpr_ | /* epsilon */
;



RelationAndExpr : RelationExpr RelationAndExpr_
;

RelationAndExpr_ : AND RelationExpr RelationAndExpr_ | /* epsilon */
;



RelationExpr : OptNot RelationExpr_
;

RelationExpr_ : Expression Comp Expression | TRUE | FALSE | ( BoolExpr )
;


OptNot : NOT | /* epsilon */
;



Comp : == | <> | < | > | <= | >=
;



Expression : MultiplicativeExpr Expression_
;

Expression_ : PMOP MultiplicativeExpr Expression_ | /* epsilon */
;

PMOP : + | -
;


MultiplicativeExpr : Term TermLoop
;

TermLoop : MultOP TERM TermLoop | /* epsilon */
;

MultOP : * | / | %
;



Term : OptMinus Term_ | IDENTIFIER ( Term__ )
;

Term_ : Var | NUMBER | ( Expression )
;

Term__ : ExpressionLoop | /* epsilon */

OptMinus : - | /* epsilon */
;

ExpressionLoop : Expression ExpressionLoop_ | /* epsilon */
;

ExpressionLoop_ : , Expression ExpressionLoop | /* epsilon */
;



Var : IDENTIFIER Var_
;

Var_ : [ Expression ] | /* epsilon */
;

%%

//epilogue - declation of function declared in prologue

int yyerror(string s)
{
  extern int yylineno;  // defined and maintained in lex.c
  extern char *yytext;  // defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}


