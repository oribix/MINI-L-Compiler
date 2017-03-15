//Prologue (types and variables in in actions - header files,
//declare yylex, yyerror, any other global indentification used by actions

%{
#include "heading.h"
#include "types.h"
#include "mil.h"
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
//4) data type of sematic values of various symboles

%union{
  int value;
  char * id;

  Expression * expr;
  Statement * stmnt;
  string * name;
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


%left MULT
%left DIV
%left MOD

%left  ADD
%right SUB

%token <value>  NUMBER
%token <id> IDENTIFIER

//nonterminal type declarations

%type <value> AddSub MultOP;
%type <value> Comp;

%type <expr> Expression;
%type <stmnt> Statement;

%type <name> Var;

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
  {
    switch($2){
      case COMPEQ:
        //cout << *$1.code << "==" << *$3.code << endl;
      break;

      case COMPNEQ:
        //cout << *$1.code << "!=" << *$3.code << endl;
      break;

      case COMPLT:
        //cout << *$1.code << "<" << *$3.code << endl;
      break;

      case COMPGT:
        //cout << *$1.code << ">" << *$3.code << endl;
      break;

      case COMPLTE:
        //cout << *$1.code << "<=" << *$3.code << endl;
      break;

      case COMPGTE:
        //cout << *$1.code << ">=" << *$3.code << endl;
      break;

      default:
        cout << "bad comparator" << endl;
      break;
    }
  }
| TRUE
| FALSE
| L_PAREN BoolExpr R_PAREN
;

Comp :
  EQ  {$$ = COMPEQ;}
| NEQ {$$ = COMPNEQ;}
| LT  {$$ = COMPLT;}
| GT  {$$ = COMPGT;}
| LTE {$$ = COMPLTE;}
| GTE {$$ = COMPGTE;}
;


Expression :
  Expression AddSub MultiplicativeExpr
  {
    $$ = new Expression();

    //check if the type of lhs is same as rhs
    SymbolType lhstype = symboltable[$1->place];
    //SymbolType rhstype = symboltable[$3->place];
    //if(lhstype != rhstype){cout << "error" << endl; exit(-1)}
    string dst = $$->place = newtemp(lhstype);
    milDeclare(dst);

    //get temps from each side
    string src1 = $1->place;
    //string src2 = $3->place;
    string src2 = "rhstemp";//placeholder

    //get operator
    string opr;
    if($2 == OPSUB)
      opr = "-";
    else
      opr = "+";

    milCompute(opr, dst, src1, src2);

    //delete the children
    delete $1;
    //delete $3;
  }
| MultiplicativeExpr
  {
    $$ = new Expression();
    //todo: fix this once MultExpr implemented

    //copy place from $1
    //string place = $1->place;
    $$->place = "MultExprTemp";//placeholder

    //delete child
    //delete $1;
  }
;

AddSub :
  ADD {$$ = OPADD}
| SUB {$$ = OPSUB}
;


MultiplicativeExpr :
  MultiplicativeExpr MultOP Term
  {
    switch($2){
      case OPMULT:
      //$$ = $1 * $3;
      cout << "mult "<< $2 << endl;
      break;

      case OPDIV:
      //$$ = $1 / $3;
      cout << "div " << $2 << endl;
      break;

      case OPMOD:
      //$$ = $1 % $3;
      cout << "mod " << $2 << endl;
      break;
    }
  }
| Term {/*$$ = $1;*/}
;

MultOP :
  MULT {$$ = OPMULT}
| DIV  {$$ = OPDIV}
| MOD  {$$ = OPMOD}
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
    {}
| IDENTIFIER
  {
    string id = $1;
    if(lookupSTE(id))
  }
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



