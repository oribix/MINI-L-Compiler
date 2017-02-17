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
"##".*		    {currentPos += yyleng;}

	/* spaces */
[[:space:]]+	{currentPos += yyleng;}

"function"	  {printf("FUNCTION\n");currentPos += yyleng; return FUNCTION;}
"beginparams"	{printf("BEGIN_PARAMS\n");currentPos += yyleng; return BEGIN_PARAMS;}
"endparams"	  {printf("END_PARAMS\n");currentPos += yyleng; return END_PARAMS;}
"beginlocals"	{printf("BEGIN_LOCALS\n");currentPos += yyleng; return BEGIN_LOCALS;}
"endlocals"	  {printf("END_LOCALS\n");currentPos += yyleng; return END_LOCALS;}
"beginbody"	  {printf("BEGIN_BODY\n");currentPos += yyleng; return BEGIN_BODY;}
"endbody"	    {printf("END_BODY\n");currentPos += yyleng; return END_BODY;}
"integer"	    {printf("INTEGER\n");currentPos += yyleng; return INTEGER;}
"array"		    {printf("ARRAY\n");currentPos += yyleng; return ARRAY;}
"of"		      {printf("OF\n");currentPos += yyleng; return OF;}
"if"		      {printf("IF\n");currentPos += yyleng; return IF;}
"then"		    {printf("THEN\n");currentPos += yyleng; return THEN;}
"endif"		    {printf("ENDIF\n");currentPos += yyleng; return ENDIF;}
"else"		    {printf("ELSE\n");currentPos += yyleng; return ELSE;}
"while"		    {printf("WHILE\n");currentPos += yyleng; return WHILE;}
"do"		      {printf("DO\n");currentPos += yyleng; return DO;}
"beginloop"	  {printf("BEGINLOOP\n");currentPos += yyleng; return BEGINLOOP;}
"endloop"	    {printf("ENDLOOP\n");currentPos += yyleng; return ENDLOOP;}
"continue"	  {printf("CONTINUE\n");currentPos += yyleng; return CONTINUE;}
"read"		    {printf("READ\n");currentPos += yyleng; return READ;}
"write"		    {printf("WRITE\n");currentPos += yyleng; return WRITE;}
"and"		      {printf("AND\n");currentPos += yyleng; return AND;}
"or"		      {printf("OR\n");currentPos += yyleng; return OR;}
"not"		      {printf("NOT\n");currentPos += yyleng; return NOT;}
"true"		    {printf("TRUE\n");currentPos += yyleng; return TRUE;}
"false"		    {printf("FALSE\n");currentPos += yyleng; return FALSE;}

	/*Comparison Operators */
"=="  {printf("EQ\n");currentPos += yyleng; return EQ;}
"<>"	{printf("NEQ\n");currentPos += yyleng; return NEQ;}
"<="	{printf("LTE\n");currentPos += yyleng; return LTE;}
">="	{printf("GTE\n");currentPos += yyleng; return GTE;}
"<"		{printf("LT\n");currentPos += yyleng; return LT;}
">"		{printf("GT\n");currentPos += yyleng; return GT;}
";"		{printf("SEMICOLON\n");currentPos += yyleng; return SEMICOLON;}
":"		{printf("COLON\n");currentPos += yyleng; return COLON;}
","		{printf("COMMA\n");currentPos += yyleng; return COMMA;}
"("		{printf("L_PAREN\n");currentPos += yyleng; return L_PAREN;}
")"		{printf("R_PAREN\n");currentPos += yyleng; return R_PAREN;}
"["		{printf("L_SQUARE_BRACKET\n");currentPos += yyleng; return L_SQUARE_BRACKET;}
"]"		{printf("R_SQUARE_BRACKET\n");currentPos += yyleng; return R_SQUARE_BRACKET;}
":="	{printf("ASSIGN\n");currentPos += yyleng; return ASSIGN;}
	/*Arithmetic Operators*/
"-"		{printf("SUB\n");currentPos += yyleng; return SUB;}
"+"		{printf("ADD\n");currentPos += yyleng; return ADD;}
"*"		{printf("MULT\n");currentPos += yyleng; return MULT;}
"/"		{printf("DIV\n");currentPos += yyleng; return DIV;}
"%"		{printf("MOD\n");currentPos += yyleng; return MOD;}

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
{ALPHA}(_*{ALPHANUM})*	{printf("IDENT %s\n" ,yytext);currentPos += yyleng;}

  /* number matcher */
{DIGIT}+	{printf("NUMBER %s\n" ,yytext);currentPos += yyleng;}

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
  /* --argv decrement the number of items in the count  	*/
  /* skip over program name */
  ++argv, --argc;
  if (argc > 0	)
    yyin = fopen(argv[0], "r");
  else
    yyin =stdin;

  yylex();
  fclose(yyin);
}
