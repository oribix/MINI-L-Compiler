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
  VList * vlist;
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

%type <nonterminal> FunctionLoop Function
%type <nonterminal> FunctionDec Params Locals Body;

%type <nonterminal> Expression MultiplicativeExpr;
%type <ntlist> ExpressionLoop;


%type <nonterminal> Statement;
%type <ntlist> StatementLoop;

%type <ntlist> IdentifierLoop;

%type <ntlist> DecLoop;
%type <nonterminal> Declaration Declaration_;

%type <nonterminal> Assignment;
%type <nonterminal> WhileLoop DoWhile IfStatement;

%type <nonterminal> Term Term_;

%type <nonterminal> BoolExpr RelationAndExpr RelationExpr RelationExpr_;

%type <ntlist> Term__;
%type <variable> Var;
%type <vlist> VarLoop;
//grammer rules - how to construct each nonterminal symbol from its parts

%%
Program :
  FunctionLoop
  {
    cout << $1->code << endl;
    delete $1;
  }
;

FunctionLoop :
  FunctionLoop Function
  {
    $$ = new NonTerminal();

    //generate code
    string code;
    code += $1->code;
    code += $2->code;
    $$->code  = code;

    delete $1;
    delete $2;
  }
| /* epsilon */
  {
    $$ = new NonTerminal();
  }
;

Function :
  FunctionDec Params Locals Body
  {
    $$ = new NonTerminal();

    //generate code
    string code;
    code += $1->code;
    code += $2->code;
    code += $3->code;
    code += $4->code;
    $$->code = code;

    delete $1;
    delete $2;
    delete $3;
    delete $4;
  }
;

FunctionDec:
  FUNCTION IDENTIFIER Semicolon
  {
    $$ = new NonTerminal();
    string functionName = $2;

    //generate code
    string code;
    code += milGenInstruction(":", functionName);
    $$->code = code;
  }
;

Params :
  BEGINPARAMS DecLoop ENDPARAMS
  {
    $$ = new NonTerminal();

    //get args
    list<NonTerminal> decs = $2->ntlist;

    //generate code
    string code;
    list<NonTerminal>::iterator it;
    for(it = decs.begin(); it != decs.end(); it ++){
      code += it->code;
    }
    $$->code = code;

    delete $2;
  }
;

Locals :
  BEGINLOCALS DecLoop ENDLOCALS
  {
    $$ = new NonTerminal();

    //get args
    list<NonTerminal> decs = $2->ntlist;

    //generate code
    string code;
    list<NonTerminal>::iterator it;
    for(it = decs.begin(); it != decs.end(); it ++){
      code += it->code;
    }
    $$->code = code;

    delete $2;
  }
;

Body :
  BEGINBODY StatementLoop ENDBODY
  {
    $$ = new NonTerminal();

    //get args
    list<NonTerminal> statements = $2->ntlist;

    //generate code
    string code;
    //for each entry in StatementLoop generate code
    list<NonTerminal>::iterator it;
    for(it = statements.begin(); it != statements.end(); it++){
      code += it->code;
    }
    $$->code = code;
  }
;

DecLoop :
  DecLoop Declaration Semicolon
  {
    $1->ntlist.push_back(*$2);
    delete $2;
  }
| /* epsilon */
  {
    $$ = new NTList();
  }
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
  {
    $$ = new NonTerminal();

    //get args
    list<NonTerminal> identifiers = $1->ntlist;
    string arraysize = $3->temp;

    //gen code
    string code;
    list<NonTerminal>::iterator it;
    for (it = identifiers.begin(); it != identifiers.end(); it++){
      if(arraysize != ""){
        code += milGenInstruction(".[]", it->temp, arraysize);
      }
      else{
        code += milDeclare(it->temp);
      }
    }
    $$->code = code;

    delete $1;
    delete $3;
  }
| error {yyerrok;}
;

Declaration_ :
  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
  {
    $$ = new NonTerminal();

    //get arguments
    stringstream s;
    s << $3;
    $$->temp = s.str();
  }
| /* epsilon */
	{
	$$ = new NonTerminal();
	}
;

IdentifierLoop :
  IdentifierLoop COMMA IDENTIFIER
  {
    NonTerminal nt = NonTerminal($3);
    $1->ntlist.push_back(nt);
  }
| IDENTIFIER
  {
    $$ = new NTList();
    NonTerminal nt = NonTerminal($1);
    $$->ntlist.push_back(nt);
  }
;

Statement :
  Assignment
  {
    $$ = new NonTerminal();
    $$->code = $1->code;
    delete $1;
  }
| IfStatement
  {
    $$ = new NonTerminal();
    $$->code = $1->code;
    delete $1;
  }
| WhileLoop
  {
    $$ = new NonTerminal();
    $$->code = $1->code;
    delete $1;
  }
| DoWhile
  {
    $$ = new NonTerminal();
    $$->code = $1->code;
    delete $1;
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
    $$ = new NonTerminal();
    $$->code = milGenInstruction("ret", $2->temp);
    delete $2;
  }



Assignment :
  Var ASSIGN Expression
  {
    $$ = new NonTerminal();

    //get arguments
    string dst = $1->temp;
    string src = $3->temp;

    //todo: check symantics
    SymbolType type = getType(dst);

    //generate code
    string code;
    code += $3->code;
    switch(type){
      case SYM_INT:
        code += milGenInstruction("=", dst, src);
      break;

      case SYM_ARR:
        code += milGenInstruction("[]=", dst, $1->index, src);
      break;

      default:
      codeGenError("Assignment", 1);
      break;
    }

    $$->code = code;

    delete $1;
    delete $3;
  }
;


IfStatement :
  IF BoolExpr THEN StatementLoop OptElse ENDIF
  {
    $$ = new NonTerminal();

    //get args
    string boolexpr = $2->temp;
    string boolExprCode = $2->code;
    list<NonTerminal> statementlist = $4->ntlist;

    //symantic check

    //generate lables
    string body = newlabel();
    string end = newlabel();
    
    //generate code
    string code;
    code += boolExprCode;
    code += milGenInstruction("?:=", body, boolexpr);
    code += milGenInstruction(":=", end);
    code += milGenInstruction(":", body);
    list<NonTerminal>::iterator it;
    for(it = statementlist.begin(); it != statementlist.end(); it++){
      code += it->code;
    }
    code += milGenInstruction(":", end);
    $$->code = code;

    delete $2;
    delete $4;
  }
;

OptElse :
  ELSE StatementLoop
| /* epsilon */
;


WhileLoop :
  WHILE BoolExpr BEGINLOOP StatementLoop ENDLOOP
  {
    $$ = new NonTerminal();

    //get args
    string boolexpr = $2->temp;
    string boolExprCode = $2->code;
    list<NonTerminal> statementlist = $4->ntlist;

    //symantic check
    //todo: check if BoolExpr is correct type
    //SymbolType type = getType(boolexpr);

    //generate labels
    string body = newlabel();//labels
    string end = newlabel();
    string begin = newlabel();

    //generate code
    string code;
    code += milGenInstruction(":", begin);
    code += boolExprCode;
    code += milGenInstruction("?:=", body, boolexpr);
    code += milGenInstruction(":=", end);
    code += milGenInstruction(":", body);
    list<NonTerminal>::iterator it;
    for(it = statementlist.begin(); it != statementlist.end(); it++){
      code += it->code;
    }
    code += milGenInstruction(":=", begin);
    code += milGenInstruction(":", end);
    $$->code = code;

    delete $2;
    delete $4;
  }
;


DoWhile :
  DO BEGINLOOP StatementLoop ENDLOOP WHILE BoolExpr
  {
    $$ = new NonTerminal();

    //get args
    list<NonTerminal> statementlist = $3->ntlist;
    string boolexpr = $6->temp;
    string boolExprCode = $6->code;

    //symantic check
    //todo: check if BoolExpr is correct type
    //SymbolType type = getType(boolexpr);
    //if(SYM_INT != type) ERROR;

    //generate labels
    string begin = newlabel();

    //generate code
    string code;
    code += milGenInstruction(":", begin);
    list<NonTerminal>::iterator it;
    for(it = statementlist.begin(); it != statementlist.end(); it++){
      code += it->code;
    }
    code += boolExprCode;
    code += milGenInstruction("?:=", begin, boolexpr);
    $$->code = code;

    delete $3;
    delete $6;
  }
;


VarLoop :
  VarLoop COMMA Var
  {
    $1->vlist.push_back(*$3);
    delete $3;
  }
| Var
  {
    $$ = new VList();
    $$->vlist.push_back(*$1);
    delete $1;
  }
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

    //get args
    string opr = $2;
    string src1 = $1->temp;
    string src2 = $3->temp;
    SymbolType lhstype = getType(src1);
    SymbolType rhstype = getType(src2);
    string dst = $$->temp = newtemp(lhstype);

    //symantic check
    //check if the type of lhs is same as rhs
    if(lhstype != rhstype)
      codeGenError("Expression", 1);

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

    //get args
    string src1 = $1->temp;
    string src2 = $3->temp;
    SymbolType lhstype = getType(src1);
    SymbolType rhstype = getType(src2);
    string dst = $$->temp = newtemp(lhstype);
    string opr = $2;

    //todo: symantic checks

    //generate code
    string code;
    code += $1->code;
    code += $3->code;
    code += milDeclare(dst);
    code += milCompute(opr, dst, src1, src2);
    $$->code = code;

    //delete the children
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



