/*Defitions* - Delcarations of simple name definitions form - name defition, include any .h files */
/* include headers here to include */
%{
  #include "heading.h"
  #include "tok.h"
  #include "mini_l.tab.h"
  
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

"function"    {currentPos += yyleng; return FUNCTION;}
"beginparams" {currentPos += yyleng; return BEGINPARAMS;}
"endparams"   {currentPos += yyleng; return ENDPARAMS;}
"beginlocals" {currentPos += yyleng; return BEGINLOCALS;}
"endlocals"   {currentPos += yyleng; return ENDLOCALS;}
"beginbody"   {currentPos += yyleng; return BEGINBODY;}
"endbody"     {currentPos += yyleng; return ENDBODY;}
"integer"     {currentPos += yyleng; return INTEGER;}
"array"       {currentPos += yyleng; return ARRAY;}
"of"          {currentPos += yyleng; return OF;}
"if"          {currentPos += yyleng; return IF;}
"then"        {currentPos += yyleng; return THEN;}
"endif"       {currentPos += yyleng; return ENDIF;}
"else"        {currentPos += yyleng; return ELSE;}
"while"       {currentPos += yyleng; return WHILE;}
"do"          {currentPos += yyleng; return DO;}
"beginloop"   {currentPos += yyleng; return BEGINLOOP;}
"endloop"     {currentPos += yyleng; return ENDLOOP;}
"continue"    {currentPos += yyleng; return CONTINUE;}
"read"        {currentPos += yyleng; return READ;}
"write"       {currentPos += yyleng; return WRITE;}
"and"         {currentPos += yyleng; return AND;}
"or"          {currentPos += yyleng; return OR;}
"not"         {currentPos += yyleng; return NOT;}
"true"        {currentPos += yyleng; return TRUE;}
"false"       {currentPos += yyleng; return FALSE;}
"return"      {currentPos += yyleng; return RETURN;}

  /*Comparison Operators */
"=="  {currentPos += yyleng; return EQ;}
"<>"  {currentPos += yyleng; return NEQ;}
"<="  {currentPos += yyleng; return LTE;}
">="  {currentPos += yyleng; return GTE;}
"<"   {currentPos += yyleng; return LT;}
">"   {currentPos += yyleng; return GT;}
";"   {currentPos += yyleng; return SEMICOLON;}
":"   {currentPos += yyleng; return COLON;}
","   {currentPos += yyleng; return COMMA;}
"("   {currentPos += yyleng; return L_PAREN;}
")"   {currentPos += yyleng; return R_PAREN;}
"["   {currentPos += yyleng; return L_SQUARE_BRACKET;}
"]"   {currentPos += yyleng; return R_SQUARE_BRACKET;}
":="  {currentPos += yyleng; return ASSIGN;}

  /*Arithmetic Operators*/
"-"   {currentPos += yyleng; return SUB;}
"+"   {currentPos += yyleng; return ADD;}
"*"   {currentPos += yyleng; return MULT;}
"/"   {currentPos += yyleng; return DIV;}
"%"   {currentPos += yyleng; return MOD;}

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
  yylval.sval = strdup(yytext);
  currentPos += yyleng;
  return IDENTIFIER;
}

  /* number matcher */
{DIGIT}+ {
  yylval.value = atoi(yytext);
  currentPos += yyleng;
  return NUMBER;
}


. {
  printErr();
  printf("unrecognized symbol \"%s\"\n", yytext);
  exit(0);
}
%%

