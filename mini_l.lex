/* 
 *cs152 Project Phase 1: Lexical Analyzer Generation Using flex

 *Due Date: 2/2/17
 *Grade Weight: 10% of total course grade
 *This project can be completed either individually or in pairs (with at most 1 other person) 
 *Overview

 *For this first part of the class project, you will use the flex tool to generate a lexical analyzer for a high-level source code language called "MINI-L". The lexical analyzer should take as input a MINI-L *program, parse it, and output the sequence of lexical tokens associated with the program.

 *The following tasks will need to be performed to complete this phase of the project.
 *Write the specification for a flex lexical analyzer for the MINI-L language. For this phase of the project, your lexical analyzer need only output the list of tokens identified from an inputted MINI-L program.
 *Example: write the flex specification in a file named mini_l.lex.
 *Run flex to generate the lexical analyzer for MINI-L using your specification.
 *Example: execute the command flex mini_l.lex. This will create a file called lex.yy.c in the current directory.
 *Compile your MINI-L lexical analyzer. This will require the -lfl flag for gcc.
 *Example: compile your lexical analyzer into the executable lexer with the following command: gcc -o lexer lex.yy.c -lfl. The program lexer should now be able to convert an inputted MINI-L program into the 
 *corresponding list of tokens.
 */
/* Need a table to handle all the reserve words */
/* Will I need two buffers to read through the MINI-L program */
/* pointer to go ahead of the token */




/*Defitions* - Delcarations of simple name definitions form - name defition, include any .h files */
/* include headers here to include */
/*#include "y.tab.h"*/
%{
  #include "heading.h"
  #include "tok.h"

  int currentLine = 1, currentPos = 1;

  void printErr(){
    printf("Error at line %d, column %d: ", currentLine, currentPos);
  }
%}

  /*%% Rules %% - Print out anything that is a digit or a math calc otherwise print an error - ignore spaces and newlines*/
ALPHA     [a-zA-Z]
DIGIT     [0-9]
ALPHANUM  {ALPHA}|{DIGIT}
IDCHAR    {ALPHANUM}|_

/* Pattern to Match                 Action to do */
/*print the name of the token on one line followed by lexeme */
%%
  /*newlines*/
"\n" {currentLine++; currentPos = 1;}

  /* Ignore Comments */
"##".*        {currentPos += yyleng;}

  /* spaces */
[[:space:]]+  {currentPos += yyleng;}

"function"    {currentPos += yyleng; return FUNCTION;}
"beginparams" {currentPos += yyleng; return BEGIN_PARAMS;}
"endparams"   {currentPos += yyleng; return END_PARAMS;}
"beginlocals" {currentPos += yyleng; return BEGIN_LOCALS;}
"endlocals"   {currentPos += yyleng; return END_LOCALS;}
"beginbody"   {currentPos += yyleng; return BEGIN_BODY;}
"endbody"     {currentPos += yyleng; return END_BODY;}
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
{ALPHA}(_*{ALPHANUM})*  {yylval.string = strdup(yytext); currentPos += yyleng;}

  /* number matcher */
{DIGIT}+  {yylval.value = atoi(yytext); currentPos += yyleng;}

. {
  printErr();
  printf("unrecognized symbol \"%s\"\n", yytext);
  exit(0);
}
%%


/*User Code */
int main(int argc, char **argv)
{
  /* argv - pointer to the row in the vector, argc is the count */
  /* ++argv move the pointer to the next item in the vector */
  /* --argv decrement the number of items in the count    */
  /* skip over program name */
  ++argv, --argc;
  if (argc > 0 )
    yyin = fopen(argv[0], "r");
  else
    yyin =stdin;

  yylex();
  fclose(yyin);
}
