


//Prologue (types and variables in in actions - header files,
//declare yylex, yyerror, any other global indentification used by actions

%{
#include "heading.h"
int yyerror(char *s);
int yyerror(string s);
int yylex(void);
%}

%error-verbose
%locations

//Bison Declartions
//1) names of termianls
//2) names of non-terminals
//3) describe operation procedures
//4) data type of sematic values of vairous symboles

%union{
  int value;
  char * string;

  struct expression_t{
    char* code;
    struct location_t{
      int lineNo;
      char* symbol;
    } place;
  }expression;

  struct statement_t{
    char* code;
    char* begin;
    char* after;
  }statement;
}

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
%left  AND
%left  OR
%right NOT
%token TRUE
%token FALSE
%token RETURN

%left EQ
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


%left <string>  MULT
%left <string>  DIV
%left <string>  MOD

%left  <string> ADD
%right <string> SUB

%token <value>  NUMBER
%token <string> IDENTIFIER
%type <statement> Statement;
%type <expression> Expression;

//grammer rules - how to construct each nonterminal symbol from its parts

%%
Program :
  FunctionLoop
;

FunctionLoop :
  FunctionLoop Function
| /* epsilon */
;

Function :
  FunctionDec Params Locals Body
;

FunctionDec:
  FUNCTION IDENTIFIER Semicolon
;

Params :
  BEGINPARAMS DecLoop ENDPARAMS
;

Locals :
  BEGINLOCALS DecLoop ENDLOCALS
;

Body :
  BEGINBODY StatementLoop ENDBODY
;

DecLoop :
  DecLoop Declaration Semicolon
| /* epsilon */
;

StatementLoop :
  StatementLoop Statement Semicolon
| Statement Semicolon
| error {yyerrok;}
;

Declaration :
  IdentifierLoop COLON Declaration_ INTEGER
| error {yyerrok;}
;

Declaration_ :
  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
| /* epsilon */
;

IdentifierLoop :
  IdentifierLoop COMMA IDENTIFIER
| IDENTIFIER
;

Statement :
  Assignment
| IfStatement
| WhileLoop
| DoWhile
| READ VarLoop
| WRITE VarLoop
| CONTINUE
| RETURN Expression
;


Assignment :
  Var ASSIGN Expression
;


IfStatement :
  IF BoolExpr THEN StatementLoop OptElse ENDIF
;

OptElse :
  ELSE StatementLoop
| /* epsilon */
;


WhileLoop :
  WHILE BoolExpr BEGINLOOP StatementLoop ENDLOOP
;


DoWhile :
  DO BEGINLOOP StatementLoop ENDLOOP WHILE BoolExpr
;


VarLoop :
  VarLoop COMMA Var
| Var
;


BoolExpr :
  BoolExpr OR RelationAndExpr
| RelationAndExpr
;



RelationAndExpr :
  RelationAndExpr AND RelationExpr
| RelationExpr
;


RelationExpr :
  RelationExpr_
| NOT RelationExpr_
;

RelationExpr_ :
  Expression Comp Expression
| TRUE
| FALSE
| L_PAREN BoolExpr R_PAREN
;

Comp :
  EQ {$$ =  "=="}
| NEQ {$$ = "<>"}
| LT {$$ = "<"}
| GT {$$ = ">"}
| LTE {$$ = ">="}
| GTE {$$ = "<="}
;


Expression :
  Expression AddSub MultiplicativeExpr
  {
    if($2 == "-")
      $$ = $1 - $3;
    else
      $$ = $1 + $3;
  }
| MultiplicativeExpr {$$ = $1;}
;

AddSub :
  ADD {$$ = "+"}
| SUB {$$ = "-"}
;


MultiplicativeExpr :
  MultiplicativeExpr MultOP Term
  {
    switch($2[0]){
      case '*': 
      $$ = $1 * $3;
      break;

      case '/':
      $$ = $1 / $3;
      break;

      case '%':
      $$ = $1 % $3;
      break;
    }
  }
| Term {$$ = $1;}
;

MultOP :
  MULT {$$ = "*"}
| DIV  {$$ = "/"}
| MOD  {$$ = "%"}
;


Term :
  Term_
| SUB Term_
| IDENTIFIER L_PAREN Term__ R_PAREN
;

Term_ :
  Var
| NUMBER
| L_PAREN Expression R_PAREN
;

Term__ :
  ExpressionLoop
| /* epsilon */
;

ExpressionLoop :
  ExpressionLoop COMMA Expression
| Expression
;

Var :
  IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
| IDENTIFIER
;

Semicolon:
  SEMICOLON
| error     {yyerrok;}

%%

//epilogue - declation of function declared in prologue

int yyerror(string s)
{
  extern char* yytext;
  extern int yylineno;

  cerr << "ERROR: " << s 
    << " at symbol \"" << yytext
    << "\" on line " << yylineno
    << endl << endl;

  return 0;
}

int yyerror(char *s)
{
  return yyerror(string(s));
}



