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
/* Need a table to handle all the reserve words */
/* Will I need two buffers to read through the MINI-L program */
/* pointer to go ahead of the token */




/*Defitions* - Delcarations of simple name definitions form - name defition, include any .h files */
/* include headers here to include */
/*#include "y.tab.h"*/
%{



%}

/*%% Rules %% - Print out anything that is a digit or a math calc otherwise print an error - ignore spaces and newlines*/
ALPHA [a-z]
DIGIT [0-9]

/* Pattern to Match                 Action to do */
/*print the name of the token on one line followed by lexeme */
%%
	/* Ignore Comments */
"##".*		{/*ignore*/} 
[[:space:]]+	{/*ignore*/} 
"function"	{printf("FUNCTION \n");}
"beginparams"	{printf("BEGIN_PARAMS \n");}
"endparams"	{printf("END_PARAMS \n");}
"beginlocals"	{printf("BEGIN_LOCALS \n");}
"endlocals"	{printf("END_LOCALS \n");}
"beginbody"	{printf("BEGIN_BODY \n");}
"endbody"	{printf("END_BODY \n");}
"integer"	{printf("INTEGER \n");}
"array"		{printf("ARRAY \n");}
"of"		{printf("OF \n");}
"if"		{printf("IF \n");}
"then"		{printf("THEN  \n");}
"endif"		{printf("ENDIF  \n");}
"else"		{printf("ELSE  \n");}
"while"		{printf("WHILE  \n");}
"do"		{printf("DO  \n");}
"beginloop"	{printf("BEGINLOOP  \n");}
"endloop"	{printf("ENDLOOP  \n");}
"continue"	{printf("CONTINUE \n");}
"read"		{printf("READ  \n");}
"write"		{printf("WRITE  \n");}
"and"		{printf("AND  \n");}
"or"		{printf("OR  \n");}
"not"		{printf("NOT  \n");}
"true"		{printf("TRUE  \n");}
"false"		{printf("FALSE  \n");}

	/*Comparison Operators */
"=="		{printf("EQ  \n");}
"<>"		{printf("NEQ  \n");}
"<="		{printf("LTE  \n");}
">="		{printf("GTE   \n");}
"<"		{printf("LT  \n");}
">"		{printf("GT  \n");}
";"		{printf("SEMICOLON   \n");}
":"		{printf("COLON   \n");}
","		{printf("COMMA   \n");}
"("		{printf("L_PAREN   \n");}
")"		{printf("R_PAREN   \n");}
"["		{printf("L_SQUARE_BRACKET   \n");}
"]"		{printf("R_SQUARE_BRACKET   \n");}
":="		{printf("ASSIGN    \n");}
	/*Arithmetic Operators*/
"-"		{printf("SUB  \n");}
"+"		{printf("ADD  \n");}
"*"		{printf("MULT  \n");}
"/"		{printf("DIV  \n");}
"%"		{printf("MOD \n");}
{ALPHA}+	{printf("IDENT %s\n" ,yytext);}  
{DIGIT}+	{printf("NUMBER %s\n" ,yytext);}  
"."		{/*ignore*/}  	
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






