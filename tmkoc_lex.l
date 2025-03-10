/* tmkoc_lex.l */
%{
#include "tmkoc_yacc.tab.h"
int line_num = 1; // Track line numbers
int column_num = 1; // Track column numbers

// Forward declaration of error function from yacc
extern void print_error(int type, const char *msg);
%}

digit           [0-9]
letter          [a-zA-Z]
identifier      {letter}({letter}|{digit})*
number          {digit}+
whitespace      [ \t\n\r]
comment         \/\/[^\n]*

%%

"="             		{ column_num += yyleng; return EQ; }
";"             		{ column_num += yyleng; return SEMICOLON; }
","             		{ column_num += yyleng; return COMMA;}
"("             		{ column_num += yyleng; return OPEN_PAREN;}
")"             		{ column_num += yyleng; return CLOSE_PAREN;}
"daya_ki_maa_ne_kaha"   { column_num += yyleng; return PRINT; }
"nahane_ja"             { column_num += yyleng; return NAHANE_JA; }
"+"             		{ column_num += yyleng; return PLUS; }
"-"             		{ column_num += yyleng; return MINUS; }
"*"             		{ column_num += yyleng; return TIMES; }
"/"             		{ column_num += yyleng; return DIVIDE; }
"tapu_int"      		{ column_num += yyleng; return TAPU_INT; }
"tapu_string"   		{ column_num += yyleng; return TAPU_STRING; }
"Gokuldham"     		{ column_num += yyleng; return GOKULDHAM; }
"{"             		{ column_num += yyleng; return OPEN_BRACE; }
"}"             		{ column_num += yyleng; return CLOSE_BRACE; }
"=="    				{ column_num += yyleng; return EQUAL; }
"!="    				{ column_num += yyleng; return NE; }
"<"     				{ column_num += yyleng; return LT; }
"<="    				{ column_num += yyleng; return LE; }
">"    				 	{ column_num += yyleng; return GT; }
">="    				{ column_num += yyleng; return GE; }
{identifier}    		{ yylval.str = strdup(yytext); column_num += yyleng; return IDENTIFIER; }
{number}        		{ yylval.num = atoi(yytext); column_num += yyleng; return NUM; }

"\""[^\"]*"\"" 			{ yylval.str = strdup(yytext); column_num += yyleng; return STRING_LITERAL; }
{comment}       		{ column_num += yyleng; } /* Ignore single-line comments */
\n                		{ line_num++; column_num = 1; } /* Track new lines */
{whitespace}    		{ column_num += yyleng; } /* Ignore whitespace */
.               		{ 
                          char msg[100];
                          snprintf(msg, sizeof(msg), "Invalid character '%s'", yytext);
                          print_error(0, msg); // 0 is ERROR_LEXICAL
                          column_num += yyleng; 
                        }

%%

int yywrap(void) {
    return 1;
}