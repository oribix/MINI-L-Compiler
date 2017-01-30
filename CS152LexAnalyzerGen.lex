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
%}

  /*%% Rules %% - Print out anything that is a digit or a math calc otherwise print an error - ignore spaces and newlines*/
ALPHA [a-zA-Z]
DIGIT [0-9]
ALPHANUM [a-zA-Z0-9]

/* Pattern to Match                 Action to do */
/*print the name of the token on one line followed by lexeme */
%%
	/*newlines*/
"\n" {currentLine++; currentPos = 1;}

	/* Ignore Comments */
"##".*		    {currentPos += yyleng;}

	/* spaces */
[[:space:]]+	{currentPos += yyleng;}

"function"	  {printf("FUNCTION \n");currentPos += yyleng;}
"beginparams"	{printf("BEGIN_PARAMS \n");currentPos += yyleng;}
"endparams"	  {printf("END_PARAMS \n");currentPos += yyleng;}
"beginlocals"	{printf("BEGIN_LOCALS \n");currentPos += yyleng;}
"endlocals"	  {printf("END_LOCALS \n");currentPos += yyleng;}
"beginbody"	  {printf("BEGIN_BODY \n");currentPos += yyleng;}
"endbody"	    {printf("END_BODY \n");currentPos += yyleng;}
"integer"	    {printf("INTEGER \n");currentPos += yyleng;}
"array"		    {printf("ARRAY \n");currentPos += yyleng;}
"of"		      {printf("OF \n");currentPos += yyleng;}
"if"		      {printf("IF \n");currentPos += yyleng;}
"then"		    {printf("THEN  \n");currentPos += yyleng;}
"endif"		    {printf("ENDIF  \n");currentPos += yyleng;}
"else"		    {printf("ELSE  \n");currentPos += yyleng;}
"while"		    {printf("WHILE  \n");currentPos += yyleng;}
"do"		      {printf("DO  \n");currentPos += yyleng;}
"beginloop"	  {printf("BEGINLOOP  \n");currentPos += yyleng;}
"endloop"	    {printf("ENDLOOP  \n");currentPos += yyleng;}
"continue"	  {printf("CONTINUE \n");currentPos += yyleng;}
"read"		    {printf("READ  \n");currentPos += yyleng;}
"write"		    {printf("WRITE  \n");currentPos += yyleng;}
"and"		      {printf("AND  \n");currentPos += yyleng;}
"or"		      {printf("OR  \n");currentPos += yyleng;}
"not"		      {printf("NOT  \n");currentPos += yyleng;}
"true"		    {printf("TRUE  \n");currentPos += yyleng;}
"false"		    {printf("FALSE  \n");currentPos += yyleng;}

	/*Comparison Operators */
"=="  {printf("EQ  \n");currentPos += yyleng;}
"<>"	{printf("NEQ  \n");currentPos += yyleng;}
"<="	{printf("LTE  \n");currentPos += yyleng;}
">="	{printf("GTE   \n");currentPos += yyleng;}
"<"		{printf("LT  \n");currentPos += yyleng;}
">"		{printf("GT  \n");currentPos += yyleng;}
";"		{printf("SEMICOLON   \n");currentPos += yyleng;}
":"		{printf("COLON   \n");currentPos += yyleng;}
","		{printf("COMMA   \n");currentPos += yyleng;}
"("		{printf("L_PAREN   \n");currentPos += yyleng;}
")"		{printf("R_PAREN   \n");currentPos += yyleng;}
"["		{printf("L_SQUARE_BRACKET   \n");currentPos += yyleng;}
"]"		{printf("R_SQUARE_BRACKET   \n");currentPos += yyleng;}
":="	{printf("ASSIGN    \n");currentPos += yyleng;}
	/*Arithmetic Operators*/
"-"		{printf("SUB  \n");currentPos += yyleng;}
"+"		{printf("ADD  \n");currentPos += yyleng;}
"*"		{printf("MULT  \n");currentPos += yyleng;}
"/"		{printf("DIV  \n");currentPos += yyleng;}
"%"		{printf("MOD \n");currentPos += yyleng;}

  /*{ALPHA}|({ALPHA}({DIGIT}|"_"|{ALPHA})*({DIGIT}|{ALPHA})*) */
{ALPHA}(_*{ALPHANUM}+)*	{printf("IDENT %s\n" ,yytext);currentPos += yyleng;}

  /* _$ {
    printf("invalid identifier %s\n", yytext);
    exit(0);
  } */

  /* 2n case {DIGIT}{ALPHANUM}* */
  /*{DIGIT}(_*{ALPHANUM}+)* {
  printf("invalid identifier %s\n", yytext);
  exit(0);*/


{DIGIT}+	{printf("NUMBER %s\n" ,yytext);currentPos += yyleng;}

. {
  printf("Error at line %d, column %d unrecognized symbol \"%s\"\n",
    currentLine,
    currentPos,
    yytext);
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
