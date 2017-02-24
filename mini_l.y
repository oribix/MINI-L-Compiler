


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

%start Program

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
%token RETURN

%token EQ
%left NEQ
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

%token NUMBER
%token IDENTIFIER

%union{
  int value;
  char * string;
}


//grammer rules - how to construct each nontermiasnl symblo from its parts

%%

Program : Function Program
  | /* epsilon */
;

Function : FUNCTION IDENTIFIER SEMICOLON
  BEGINPARAMS DecLoop ENDPARAMS
  BEGINLOCALS DecLoop ENDLOCALS
  BEGINBODY Statement SEMICOLON StatementLoop ENDBODY
;

DecLoop : DecLoop Declaration SEMICOLON
  | /* epsilon */
;

StatementLoop : StatementLoop Statement SEMICOLON
  | Statement SEMICOLON
;


Declaration : IdentifierLoop COLON Declaration_ INTEGER
;

Declaration_ : ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
  | /* epsilon */
;

IdentifierLoop : IdentifierLoop COMMA IDENTIFIER
  | IDENTIFIER
;



Statement : Assignment | IfStatement | WhileLoop | DoWhile | READ VarLoop |
  WRITE VarLoop | CONTINUE | RETURN Expression
;


Assignment : Var ASSIGN Expression


IfStatement : IF BoolExpr THEN StatementLoop OptElse ENDIF
;

OptElse : ELSE StatementLoop
  | /* epsilon */
;


WhileLoop : WHILE BoolExpr BEGINLOOP StatementLoop ENDLOOP
;


DoWhile : DO BEGINLOOP StatementLoop ENDLOOP WHILE BoolExpr
;


VarLoop : VarLoop COMMA Var
  | Var
;


BoolExpr : BoolExpr OR RelationAndExpr
  | RelationAndExpr
;



RelationAndExpr : RelationAndExpr AND RelationExpr
  | RelationExpr
;


RelationExpr : OptNot RelationExpr_
;

RelationExpr_ : Expression Comp Expression
  | TRUE
  | FALSE
  | L_PAREN BoolExpr R_PAREN
;


OptNot : NOT
  | /* epsilon */
;



Comp : EQ
  | NEQ
  | LT
  | GT
  | LTE
  | GTE
;


Expression : Expression AddSub MultiplicativeExpr
  | MultiplicativeExpr
;

AddSub : ADD
  | SUB
;


MultiplicativeExpr : MultiplicativeExpr MultOP Term
  | Term
;


MultOP : MULT
  | DIV
  | MOD
;


Term : OptMinus Term_
  | IDENTIFIER L_PAREN Term__ R_PAREN
;

Term_ : Var
  | NUMBER
  | L_PAREN Expression R_PAREN
;

Term__ : ExpressionLoop
  | /* epsilon */
;

OptMinus : SUB
  | /* epsilon */
;

ExpressionLoop : ExpressionLoop COMMA Expression
  | Expression
;



Var : IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
| IDENTIFIER
;

%%

//epilogue - declation of function declared in prologue

int yyerror(string s)
{
  extern int currentLine;  // defined and maintained in lex.c
  extern char *yytext;  // defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol " << yytext << " on line " << currentLine << endl;
 
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}


