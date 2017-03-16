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

  NonTerminal * nonterminal;
  string * temp;
  char* opval;
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

%type <opval> AddSub MultOP;
%type <value> Comp;

%type <nonterminal> Expression MultiplicativeExpr;
%type <nonterminal> Term Term_ Term__;
%type <temp> Var;

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
    $$ = new NonTerminal();

    //check if the type of lhs is same as rhs
    SymbolType lhstype = symboltable[$1->temp];
    SymbolType rhstype = symboltable[$3->temp];
    if(lhstype != rhstype)
      codeGenError("Expression", 1);

    //create new temp an declare it
    string dst = $$->temp = newtemp(lhstype); 
    milDeclare(dst);

    //get temps from each side
    string src1 = $1->temp;
    string src2 = $3->temp;

    //get operator
    string opr = $2;

    //generate mil instruction
    milCompute(opr, dst, src1, src2);

    //delete the children
    delete $1;
    delete $3;
  }
| MultiplicativeExpr
  {
    $$ = new NonTerminal($1->temp);
    delete $1;
  }
;

AddSub :
  ADD {$$ = "+";}
| SUB {$$ = "-";}
;


MultiplicativeExpr :
  MultiplicativeExpr MultOP Term
  {
    $$ = new NonTerminal();

    //get types of lhs and rhs
    SymbolType lhstype = getType($1->temp);
    //SymbolType rhstype = getType($3->temp);

    //create new temp and declare it
    string dst = $$->temp = newtemp(lhstype);
    milDeclare(dst);

    string opr = $2;
    string src1 = $1->temp;
    string src2 = "TermTemp";

    //generate mil instruction
    milCompute(opr, dst, src1, src2);

    delete $1;
    delete $3
  }
| Term
  {
    $$ = new NonTerminal($1->temp);
    delete $1;
  }
;

MultOP :
  MULT {$$ = "*";}
| DIV  {$$ = "/";}
| MOD  {$$ = "%";}
;


Term :
  Term_
  {
    $$ = new NonTerminal();
    $$->temp = "Term_Temp";
    //delete $1;
  }
| SUB Term_
  {
    $$ = new NonTerminal();

    //todo:get type of term_
    SymbolType type;
    //type = getType($2->temp);
    type = SYM_INT;

    //create new temp and declare it
    string dst = $$->temp = newtemp(type);
    milDeclare(dst);

    string opr = "-";
    string src1 = "0";
    string src2 = "Term_Temp";

    milCompute(opr, dst, src1, src2);

    //delete $2;
  }
| IDENTIFIER L_PAREN Term__ R_PAREN
  {
    $$ = new NonTerminal();

    string dst = $$->temp = newtemp(SYM_INT);
    milDeclare(dst);

    cout << "add param for each expression in Term__" << endl;

    string functionName = $1;
    milFunctionCall(functionName, dst);
    //delete $3;
  }
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



