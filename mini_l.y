//Prologue (types and variables in in actions - header files,
//declare yylex, yyerror, any other global indentification used by actions

%{
#include "heading.h"
#include "types.h"
#include "mil.h"
#include <list>
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
  char * sval;

  NonTerminal * nonterminal;
  Variable * variable;
  NTList * ntlist;
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
%token <sval> IDENTIFIER

//nonterminal type declarations

%type <sval> AddSub MultOP;
%type <sval> Comp;

%type <nonterminal> Expression MultiplicativeExpr;
%type <ntlist> ExpressionLoop;

%type <nonterminal> Term Term_;

%type <nonterminal> BoolExpr RelationAndExpr RelationExpr RelationExpr_;

%type <ntlist> Term__;
%type <variable> Var;

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
  {
    $$ = new NonTerminal();

    SymbolType type = getType($1->temp);
    string dst = $$->temp = newtemp(type);
    string src1 = $1->temp;
    string src2 = $3->temp;

    //generate mil functions
    milDeclare(dst);
    milCompute("||", dst, src1, src2);

    delete $1;
    delete $3;
  }
| RelationAndExpr
  {
    $$ = new NonTerminal($1->temp);
    delete $1;
  }
;



RelationAndExpr :
  RelationAndExpr AND RelationExpr
  {
    $$ = new NonTerminal();

    SymbolType type = getType($1->temp);
    string dst = $$->temp = newtemp(type);
    string src1 = $1->temp;
    string src2 = $3->temp;

    //generate mil functions
    milDeclare(dst);
    milCompute("&&", dst, src1, src2);

    delete $1;
    delete $3;
  }
| RelationExpr
  {
    $$ = new NonTerminal($1->temp);
    delete $1;
  }
;


RelationExpr :
  RelationExpr_
  {
    $$ = new NonTerminal($1->temp);
    delete $1;
  }
| NOT RelationExpr_
  {
    $$ = new NonTerminal();

    //print mil code to invert RelationExpr_
    string dst = $$->temp = newtemp(SYM_INT);
    milDeclare(dst);
    string src = $2->temp;
    milCompute("!", dst, src);

    delete $2;
  }
;

RelationExpr_ :
  Expression Comp Expression
  {
    $$ = new NonTerminal();
    string lhs = $1->temp;
    string rhs = $3->temp;

    string dst = $$->temp = newtemp(SYM_INT);
    milDeclare(dst);

    string opr = $2;
    milCompute(opr, dst, lhs, rhs);

    delete $1;
    delete $3;
  }
| TRUE
  {
    $$ = new NonTerminal("1");
  }
| FALSE
  {
    $$ = new NonTerminal("0");
  }
| L_PAREN BoolExpr R_PAREN
  {
    $$ = new NonTerminal("BoolExprTemp");
  }
;

Comp :
  EQ  {$$ = "==";}
| NEQ {$$ = "!=";}
| LT  {$$ = "<";}
| GT  {$$ = ">";}
| LTE {$$ = "<=";}
| GTE {$$ = ">=";}
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
    string src2 = $3->temp;

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
    $$->temp = $1->temp;
    delete $1;
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
    string src2 = $2->temp;

    milCompute(opr, dst, src1, src2);

    delete $2;
  }
| IDENTIFIER L_PAREN Term__ R_PAREN
  {
    $$ = new NonTerminal();

    string dst = $$->temp = newtemp(SYM_INT);
    milDeclare(dst);

    //add param for each expression in Term__
    list<NonTerminal> params = $3->ntlist;
    list<NonTerminal>::iterator it;
    for(it = params.begin(); it != params.end(); it++){
      string temp = it->temp;
      milGenInstruction("param", temp);
    }

    //call function
    string functionName = $1;
    milFunctionCall(functionName, dst);
    delete $3;
  }
;

Term_ :
  Var
  {
    $$ = new NonTerminal();

    //get var type
    string id = $1->temp;
    SymbolType type = getType(id);
    switch(type){
      case SYM_INT:
      //pass up value
      $$->temp = $1->temp;
      break;

      case SYM_ARR:
      {
        //dereference array
        string dst = $$->temp = newtemp(SYM_INT);
        string src = $1->temp;
        string index = $1->index;

        //generate instructions
        milDeclare(dst);
        milGenInstruction("=[]", dst, src, index);
      }
      break;

      default:
      codeGenError("Term_", 1);
      break;
    }

    delete $1;
  }
| NUMBER
  {
    $$ = new NonTerminal();
    stringstream s;
    s << $1;
    $$->temp = s.str();
  }
| L_PAREN Expression R_PAREN
  {
    $$ = new NonTerminal();
    $$->temp = $2->temp;
    delete $2;
  }
;

Term__ :
  ExpressionLoop
  {
    //pass up list of expressions
    $$ = $1;
  }
| /* epsilon */
  {
    //return empty list
    $$ = new NTList;
  }
;

ExpressionLoop :
  ExpressionLoop COMMA Expression
  {
    $1->ntlist.push_back(*$3);
    delete $3;
  }
| Expression
  {
    $$ = new NTList();
    $$->ntlist.push_back(*$1);
    delete $1;
  }
;

Var :
  IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
  {
    //todo:
    //may need new class for this...
    //identifier[index] can be written or read depending on context
    $$ = new Variable();
    string id = $1;

    //todo: delete this nephew
    //should be handled by declaration rule
    symboltable[id] = SYM_ARR;
    if(!lookupSTE(id)){
      //codeGenError("Var", 2);
      cout << id << " was not declared!" << endl;
    }

    $$->temp = id;
    $$->index = $3->temp;

    delete $3;
  }
| IDENTIFIER
  {
    $$ = new Variable();
    string id = $1;

    //todo: delete this nephew
    //should be handled by declaration rule
    symboltable[id] = SYM_INT;
    if(!lookupSTE(id)){
      //codeGenError("Var", 2);
      cout << id << " was not declared!" << endl;
    }

    $$->temp = id;
    $$->index = -1;
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



