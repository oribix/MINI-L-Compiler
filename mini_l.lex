/*Defitions* - Delcarations of simple name definitions form - name:wq: defition, include any .h files */
/* include headers here to include */
%{
  #include "heading.h"
  #include "tok.h"
  #include "mini_l.tab.h"
  #include "string.h"

  int currentLine = 1, currentPos = 1;

  void printErr(){
    printf("Error at line %d, column %d: ", currentLine, currentPos);
  }
%}

%option yylineno

  /*%% Rules %% - Print out anything that is a digit or a math calc otherwise print an error - ignore spaces and newlines*/
ALPHA     [a-zA-Z]
DIGIT     [0-9]
ALPHANUM  {ALPHA}|{DIGIT}
IDCHAR    {ALPHANUM}|_

%%
  /*newlines*/
"\n" {currentLine++; currentPos = 1;}

  /* Ignore Comments */
"##".*        {currentPos += yyleng;}

  /* spaces */
[[:space:]]+  {currentPos += yyleng;}

"function"    {currentPos += yyleng; return yy::parser::make_FUNCTION(currentPos);}
"beginparams" {currentPos += yyleng; return yy::parser::make_BEGINPARAMS(currentPos);}
"endparams"   {currentPos += yyleng; return yy::parser::make_ENDPARAMS(currentPos);}
"beginlocals" {currentPos += yyleng; return yy::parser::make_BEGINLOCALS(currentPos);}
"endlocals"   {currentPos += yyleng; return yy::parser::make_ENDLOCALS(currentPos);}
"beginbody"   {currentPos += yyleng; return yy::parser::make_BEGINBODY(currentPos);}
"endbody"     {currentPos += yyleng; return yy::parser::make_ENDBODY(currentPos);}
"integer"     {currentPos += yyleng; return yy::parser::make_INTEGER(currentPos);}
"array"       {currentPos += yyleng; return yy::parser::make_ARRAY(currentPos);}
"of"          {currentPos += yyleng; return yy::parser::make_OF(currentPos);}
"if"          {currentPos += yyleng; return yy::parser::make_IF(currentPos);}
"then"        {currentPos += yyleng; return yy::parser::make_THEN(currentPos);}
"endif"       {currentPos += yyleng; return yy::parser::make_ENDIF(currentPos);}
"else"        {currentPos += yyleng; return yy::parser::make_ELSE(currentPos);}
"while"       {currentPos += yyleng; return yy::parser::make_WHILE(currentPos);}
"do"          {currentPos += yyleng; return yy::parser::make_DO(currentPos);}
"beginloop"   {currentPos += yyleng; return yy::parser::make_BEGINLOOP(currentPos);}
"endloop"     {currentPos += yyleng; return yy::parser::make_ENDLOOP(currentPos);}
"continue"    {currentPos += yyleng; return yy::parser::make_CONTINUE(currentPos);}
"read"        {currentPos += yyleng; return yy::parser::make_READ(currentPos);}
"write"       {currentPos += yyleng; return yy::parser::make_WRITE(currentPos);}
"and"         {currentPos += yyleng; return yy::parser::make_AND(currentPos);}
"or"          {currentPos += yyleng; return yy::parser::make_OR(currentPos);}
"not"         {currentPos += yyleng; return yy::parser::make_NOT(currentPos);}
"true"        {currentPos += yyleng; return yy::parser::make_TRUE(currentPos);}
"false"       {currentPos += yyleng; return yy::parser::make_FALSE(currentPos);}
"return"      {currentPos += yyleng; return yy::parser::make_RETURN(currentPos);}

  /*Comparison Operators */
"=="  {currentPos += yyleng; return yy::parser::make_EQ(currentPos);}
"<>"  {currentPos += yyleng; return yy::parser::make_NEQ(currentPos);}
"<="  {currentPos += yyleng; return yy::parser::make_LTE(currentPos);}
">="  {currentPos += yyleng; return yy::parser::make_GTE(currentPos);}
"<"   {currentPos += yyleng; return yy::parser::make_LT(currentPos);}
">"   {currentPos += yyleng; return yy::parser::make_GT(currentPos);}
";"   {currentPos += yyleng; return yy::parser::make_SEMICOLON(currentPos);}
":"   {currentPos += yyleng; return yy::parser::make_COLON(currentPos);}
","   {currentPos += yyleng; return yy::parser::make_COMMA(currentPos);}
"("   {currentPos += yyleng; return yy::parser::make_L_PAREN(currentPos);}
")"   {currentPos += yyleng; return yy::parser::make_R_PAREN(currentPos);}
"["   {currentPos += yyleng; return yy::parser::make_L_SQUARE_BRACKET(currentPos);}
"]"   {currentPos += yyleng; return yy::parser::make_R_SQUARE_BRACKET(currentPos);}
":="  {currentPos += yyleng; return yy::parser::make_ASSIGN(currentPos);}

  /*Arithmetic Operators*/
"-"   {currentPos += yyleng; return yy::parser::make_SUB(currentPos);}
"+"   {currentPos += yyleng; return yy::parser::make_ADD(currentPos);}
"*"   {currentPos += yyleng; return yy::parser::make_MULT(currentPos);}
"/"   {currentPos += yyleng; return yy::parser::make_DIV(currentPos);}
"%"   {currentPos += yyleng; return yy::parser::make_MOD(currentPos);}

  /* matches invalid identifiers that end in _ */
{IDCHAR}*_ {
  printErr();
  printf("identifier %s cannot end with an underscore\n", yytext);
  exit(0);
}

  /* matches invalid identifiers that begin with numbers */
{DIGIT}+({ALPHA}|_){IDCHAR}* {
  printErr();
  printf("identifier %s must begin with a letter\n", yytext);
  exit(0);
}

  /* matches invalid identifiers that begin with _ */
_{IDCHAR}* {
  printErr();
  printf("identifier %s must begin with a letter\n", yytext);
  exit(0);
}

  /* identifier matcher */
{ALPHA}(_*{ALPHANUM})*  {
  yylval.string = strdup(yytext);
  currentPos += yyleng;
  return yy::parser::make_IDENTIFIER(yytext, currentPos);
}

  /* number matcher */
{DIGIT}+ {
  yylval.value = atoi(yytext);
  currentPos += yyleng;
  return yy::parser::make_NUMBER(text_to_int (yytext), currentPos);
}


. {
  printErr();
  printf("unrecognized symbol \"%s\"\n", yytext);
  exit(0);
}
%%

