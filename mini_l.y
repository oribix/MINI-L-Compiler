


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


//grammer rules - how to construct each nonterminal symbol from its parts

%%
Program :
  FunctionLoop
    {cout << "Program -> FunctionLoop" << endl;}
;

FunctionLoop :
  FunctionLoop Function
    {cout << "FunctionLoop -> Function FunctionLoop" << endl;}
| /* epsilon */
    {cout << "FunctionLoop -> epsilon" << endl;}
;

Function :
  FunctionDec Params Locals Body
    {cout << "FUNCTION -> FunctionDec Params Locals Body" << endl;}
;

FunctionDec:
  FUNCTION IDENTIFIER Semicolon
    {cout << "FunctionDec -> FUNCTION IDENTIFIER Semicolon" << endl;}
;

Params :
  BEGINPARAMS DecLoop ENDPARAMS
    {cout << "Params -> BEGINPARAMS DecLoop ENDPARAMS" << endl;}
;

Locals :
  BEGINLOCALS DecLoop ENDLOCALS
    {cout << "Locals -> BEGINLOCALS DecLoop ENDLOCALS" << endl;}
;

Body :
  BEGINBODY StatementLoop ENDBODY
    {cout << "Body -> BEGINBODY StatementLoop ENDBODY" << endl;}
;

DecLoop :
  DecLoop Declaration Semicolon
    {cout << "DecLoop -> DecLoop Declaration Semicolon" << endl;}
| /* epsilon */
    {cout << "DecLoop -> epsilon" << endl;}
;

StatementLoop :
  StatementLoop Statement Semicolon
    {cout << "StatementLoop -> StatementLoop Statement Semicolon" << endl;}
| Statement Semicolon
    {cout << "StatementLoop -> Statement Semicolon" << endl;}
;

Declaration :
  IdentifierLoop COLON Declaration_ INTEGER
    {cout << "Declaration -> IdentifierLoop COLON Declaration_ INTEGER" << endl;}
;

Declaration_ :
  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
    {
      cout << "Declaration_ > /ARRAY L_SQUARE_BRACKET NUMBER "
      << yylval.value << " R_SQUARE_BRACKET OF" << endl;
    }
| /* epsilon */
    {cout << "Declaration_ > epsilon" << endl;}
;

IdentifierLoop :
  IdentifierLoop COMMA IDENTIFIER
    {cout << "IdentifierLoop -> IdentifierLoop COMMA IDENTIFIER" << endl;}
| IDENTIFIER
    {cout << "IdentifierLoop -> IDENTIFIER" << endl;}
;

Statement :
  Assignment        {cout << "Statement -> Assignment " << endl;}
| IfStatement       {cout << "Statement -> IfStatement" << endl;}
| WhileLoop         {cout << "Statement -> WhileLoop " << endl;}
| DoWhile           {cout << "Statement -> DoWhile " << endl;}
| READ VarLoop      {cout << "Statement -> READ VarLoop " << endl;}
| WRITE VarLoop     {cout << "Statement -> WRITE VarLoop " << endl;}
| CONTINUE          {cout << "Statement -> CONTINUE " << endl;}
| RETURN Expression {cout << "Statement -> RETURN Expression" << endl;}
;


Assignment :
  Var ASSIGN Expression
    {cout << "Assignment -> Var ASSIGN Expression" << endl;}
;


IfStatement :
  IF BoolExpr THEN StatementLoop OptElse ENDIF
    {cout << "IfStatement -> IF BoolExpr THEN StatementLoop OptElse ENDIF"  << endl;}
;

OptElse :
  ELSE StatementLoop
    {cout << "OptElse -> ELSE StatementLoop"  << endl;}
| /* epsilon */
    {cout << "OptElse -> epsilon" << endl;}
;


WhileLoop :
  WHILE BoolExpr BEGINLOOP StatementLoop ENDLOOP
    {cout << "WhileLoop -> WHILE BoolExpr BEGINLOOP StatementLoop ENDLOOP" << endl;}
;


DoWhile :
  DO BEGINLOOP StatementLoop ENDLOOP WHILE BoolExpr
    {cout << "DoWhile -> DO BEGINLOOP StatementLoop ENDLOOP WHILE BoolExpr" << endl;}
;


VarLoop :
  VarLoop COMMA Var
    {cout << "VarLoop -> VarLoop COMMA Var" << endl;}
| Var
    {cout << "VarLoop -> Var" << endl;}
;


BoolExpr :
  BoolExpr OR RelationAndExpr
    {cout << "BoolExpr -> BoolExpr OR RelationAndExpr" << endl;}
| RelationAndExpr
    {cout << "BoolExpr -> RelationAndExpr" << endl;}
;



RelationAndExpr :
  RelationAndExpr AND RelationExpr
    {cout << "RelationAndExpr -> RelationAndExpr AND RelationExpr" << endl;}
| RelationExpr
    {cout << "RelationAndExpr -> RelationExpr" << endl;}
;


RelationExpr :
  RelationExpr_
    {cout << "RelationExpr -> RelationExpr_" << endl;}
| NOT RelationExpr_
    {cout << "RelationExpr -> NOT RelationExpr_" << endl;}
;

RelationExpr_ :
  Expression Comp Expression
    {cout << "RelationExpr_ -> Expression Comp Expression" << endl;}
| TRUE
    {cout << "RelationExpr_ -> TRUE" << endl;}
| FALSE
    {cout << "RelationExpr_ -> FALSE" << endl;}
| L_PAREN BoolExpr R_PAREN
    {cout << "RelationExpr_ -> L_PAREN BoolExpr R_PAREN" << endl;} 
;


Comp :
  EQ
    {cout << "Comp -> EQ" << endl;}
| NEQ
    {cout << "Comp -> NEQ" << endl;}
| LT
    {cout << "Comp -> LT" << endl;}
| GT
    {cout << "Comp -> GT" << endl;}
| LTE
    {cout << "Comp -> LTE" << endl;}
| GTE
    {cout << "Comp -> GTE" << endl;}
;


Expression :
  Expression AddSub MultiplicativeExpr
    {cout << "Expression -> Expression AddSub MultiplicativeExpr" << endl;}
| MultiplicativeExpr
    {cout << "Expression -> MultiplicativeExpr" << endl;}
;

AddSub :
  ADD
    {cout << "AddSub -> ADD" << endl;}
| SUB
    {cout << "AddSub -> SUB" << endl;}
;


MultiplicativeExpr :
  MultiplicativeExpr MultOP Term
    {cout << "MultiplicativeExpr -> MultiplicativeExpr MultOP Term" << endl;}
| Term
    {cout << "MultiplicativeExpr -> Term" << endl;}
;

MultOP :
  MULT
    {cout << "MultOP -> MULT" << endl;}
| DIV
    {cout << "MultOP ->  DIV" << endl;}
| MOD
    {cout << "MultOP ->  MOD" << endl;}
;


Term :
  Term_
    {cout << "Term -> Term_" << endl;}
| SUB Term_
    {cout << "Term -> SUB Term_" << endl;}
| IDENTIFIER L_PAREN Term__ R_PAREN
    {cout << "Term -> IDENTIFIER L_PAREN Term__ R_PAREN" << endl;}
;

Term_ :
  Var
    {cout << "Term_ ->  Var" << endl;}
| NUMBER
    {cout << "Term_ ->  NUMBER " << yylval.value << endl;}
| L_PAREN Expression R_PAREN
    {cout << "Term_ -> L_PAREN Expression R_PAREN" << endl;}
;

Term__ :
  ExpressionLoop
    {cout << "Term__ -> ExpressionLoop " << endl;}
| /* epsilon */
    {cout << "Term__ ->  epsilon" << endl;}
;

ExpressionLoop :
  ExpressionLoop COMMA Expression
    {cout << "ExpressionLoop -> ExpressionLoop COMMA Expression" << endl;}
| Expression
    {cout << "ExpressionLoop ->  Expression" << endl;}
;

Var :
  IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
    {cout << "Var -> IDENTIFIER L_SQUARE_BRACKET EXPRESSION R_SQUARE_BRACKET" << endl;}
| IDENTIFIER
    {cout << "Var -> IDENTIFIER" << endl;}
;

Semicolon:
  SEMICOLON {cout << "Semicolon -> SEMICOLON" << endl;}
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


