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

%type <nonterminal> FunctionDec;

%type <nonterminal> Expression MultiplicativeExpr;
%type <ntlist> ExpressionLoop;

%type <nonterminal> Statement;
%type <ntlist> StatementLoop;

%type <nonterminal> Assignment;

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
  {
    string functionName = $2;
    cout << milGenInstruction(":", functionName);
  }
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
  {
    $1->ntlist.push_back(*$2);
    delete $2;
  }
| Statement Semicolon
  {
    $$ = new NTList();
    $$->ntlist.push_back(*$1);
    delete $1;
  }
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
  {
  $$ = new NonTerminal();
  }
| IfStatement
  {
  $$ = new NonTerminal();
  }
| WhileLoop
  {
  $$ = new NonTerminal();
  }
| DoWhile
  {
  $$ = new NonTerminal();
  }
| READ VarLoop
  {
  $$ = new NonTerminal();
  }
| WRITE VarLoop
  {
  $$ = new NonTerminal();
  }
| CONTINUE
  {
  $$ = new NonTerminal();
  }
| RETURN Expression
  {
    cout << milGenInstruction("ret", $2->temp);
    delete $2;
  }
;


Assignment :
  Var ASSIGN Expression
  {
    string id = $1->temp;

    string dst;
    string src = $3->temp;

    SymbolType type = getType(id);
    switch(type){
      case SYM_INT:
      {
        dst = id;

        //generate code
        string code;
        code += milGenInstruction("=", dst, src);
        $$->code = code;
      }
      break;

      case SYM_ARR:
      {
        dst = id;
        string index = $1->index;

        //generate code
        string code;
        code += milGenInstruction("[]=", dst, index, src);
        $$->code = code;
      }
      break;

      default:
      codeGenError("Assignment", 1);
      break;
    }

    cout << $$->code;

    delete $1;
    delete $3;
  }
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
  {
    //labels
    string begin = newlabel();
    string end = newlabel();
    string conditional = newlabel();

    string boolexpr = $2->temp;
    string boolExprCode = $2->code;

    //todo: check if BoolExpr is correct type
    //SymbolType type = getType(boolexpr);


    //generate code
    //generate label before boolean calculation
    cout << milGenInstruction(":", conditional);
    //todo: calculate the boolean
    cout << boolExprCode << flush;
    cout << milGenInstruction("?:=", begin, boolexpr);
    cout << milGenInstruction(":=", end);
    cout << milGenInstruction(":", begin);
    cout << endl << "statements go here!"<< endl << endl;
    cout << milGenInstruction(":=", begin);
    cout << milGenInstruction(":", end);

    delete $2;
    //delete $4;
  }
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

    //generate code
    string code;
    code += $1->code;
    code += $3->code;
    code += milDeclare(dst);
    code += milCompute("||", dst, src1, src2);
    $$->code = code;

    delete $1;
    delete $3;
  }
| RelationAndExpr
  {
    $$ = new NonTerminal($1->temp);
    $$->code = $1->code;
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

    //generate code
    string code;
    code += $1->code;
    code += $3->code;
    code += milDeclare(dst);
    code += milCompute("&&", dst, src1, src2);
    $$->code = code;

    delete $1;
    delete $3;
  }
| RelationExpr
  {
    $$ = new NonTerminal($1->temp);
    $$->code = $1->code;
    delete $1;
  }
;


RelationExpr :
  RelationExpr_
  {
    $$ = new NonTerminal($1->temp);
    $$->code = $1->code;
    delete $1;
  }
| NOT RelationExpr_
  {
    $$ = new NonTerminal();

    //print mil code to invert RelationExpr_
    string dst = $$->temp = newtemp(SYM_INT);
    string src = $2->temp;

    //generate code
    string code;
    code += $2->code;
    code += milDeclare(dst);
    code += milCompute("!", dst, src);
    $$->code = code;

    delete $2;
  }
;

RelationExpr_ :
  Expression Comp Expression
  {
    $$ = new NonTerminal();

    //get arguments
    string lhs = $1->temp;
    string rhs = $3->temp;
    string dst = $$->temp = newtemp(SYM_INT);
    string opr = $2;

    //generate code
    string code;
    code += $1->code;
    code += $3->code;
    code += milDeclare(dst);
    code += milCompute(opr, dst, lhs, rhs);
    $$->code = code;

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
    $$ = new NonTerminal();
    $$->temp = $2->temp;
    $$->code = $2->code;

    delete $2;
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

    //get args
    string dst = $$->temp = newtemp(lhstype);
    string src1 = $1->temp;
    string src2 = $3->temp;
    string opr = $2;

    //generate code
    string code;
    code += $1->code;
    code += $3->code;
    code += milDeclare(dst);
    code += milCompute(opr, dst, src1, src2);
    $$->code = code;

    //delete the children
    delete $1;
    delete $3;
  }
| MultiplicativeExpr
  {
    $$ = new NonTerminal($1->temp);
    $$->code = $1->code;
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

    //get args
    string dst = $$->temp = newtemp(lhstype);
    string opr = $2;
    string src1 = $1->temp;
    string src2 = $3->temp;

    //generate code
    string code;
    code += $1->code;
    code += $3->code;
    code += milDeclare(dst);
    code += milCompute(opr, dst, src1, src2);

    delete $1;
    delete $3
  }
| Term
  {
    $$ = new NonTerminal($1->temp);
    $$->code = $1->code;
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
    $$->code = $1->code;
    delete $1;
  }
| SUB Term_
  {
    $$ = new NonTerminal();

    //todo:get type of term_
    SymbolType type = getType($2->temp);

    //get args
    string opr = "-";
    string dst = $$->temp = newtemp(type);
    string src1 = "0";
    string src2 = $2->temp;

    //generate code
    string code;
    code += $2->code;
    code += milDeclare(dst);
    code += milCompute(opr, dst, src1, src2);

    delete $2;
  }
| IDENTIFIER L_PAREN Term__ R_PAREN
  {
    $$ = new NonTerminal();

    //get arguments
    string dst = $$->temp = newtemp(SYM_INT);
    string functionName = $1;
    list<NonTerminal> params = $3->ntlist;

    //generate code
    string code;
    code += milDeclare(dst);
    //add params
    list<NonTerminal>::iterator it;
    for(it = params.begin(); it != params.end(); it++){
      code += milGenInstruction("param", it->temp);
    }
    code += milFunctionCall(functionName, dst);

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
        //get args
        string dst = $$->temp = newtemp(SYM_INT);
        string src = $1->temp;
        string index = $1->index;

        //generate code
        string code;
        code += milDeclare(dst);
        code += milGenInstruction("=[]", dst, src, index);
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
    $$ = new NonTerminal($2->temp);
    $$->code = $2->code;
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
    $$ = new Variable();
    string id = $1;

    //todo: delete this nephew
    //should be handled by declaration rule
    symboltable[id] = SYM_ARR;
    if(!lookupSTE(id)){
      //codeGenError("Var", 2);
      cout << id << " was not declared!" << endl;
    }

    //get args
    //string dst = $$->temp = newtemp(SYM_ARR);
    $$->temp = id;
    $$->index = $3->temp;

    //generate code
    //cout << milDeclare(dst);

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

    //get args
    //string dst = $$->temp = newtemp(SYM_INT);
    $$->temp = id;
    $$->index = -1;

    //generate code
    //cout << milDeclare(dst);
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



