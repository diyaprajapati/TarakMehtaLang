%{
#include "tmkoc_yacc.tab.h"
%}

digit           [0-9]
letter          [a-zA-Z]
identifier      {letter}({letter}|{digit})*
number          {digit}+
whitespace      [ \t\n\r]
comment         \/\/[^\n]*

%%

"="             		{ return EQ; }
";"             		{ return SEMICOLON; }
","             		{ return COMMA;}
"("             		{ return OPEN_PAREN;}
")"             		{ return CLOSE_PAREN;}
"daya_ki_maa_ne_kaha"   { return PRINT; }
"bapuji_sahmat" 		{ return BAPUJI_SAHMAT; }
"bapuji_asahmat" 		{ return BAPUJI_ASAHMAT; }
"nahane_ja"             { return NAHANE_JA; }
"+"             		{ return PLUS; }
"-"             		{ return MINUS; }
"*"             		{ return TIMES; }
"/"             		{ return DIVIDE; }
"tapu_int"      		{ return TAPU_INT; }
"tapu_string"   		{ return TAPU_STRING; }
"Gokuldham"     		{ return GOKULDHAM; }
"{"             		{ return OPEN_BRACE; }
"}"             		{ return CLOSE_BRACE; }
"=="    				{ return EQUAL; }
"!="    				{ return NE; }
"<"     				{ return LT; }
"<="    				{ return LE; }
">"    				 	{ return GT; }
">="    				{ return GE; }
{identifier}    		{ yylval.str = strdup(yytext); return IDENTIFIER; }
{number}        		{ yylval.num = atoi(yytext); return NUM; }

"\""[^\"]*"\"" 			{ yylval.str = strdup(yytext); return STRING_LITERAL; }
{comment}       		; /* Ignore single-line comments */
{whitespace}    		;
.               		{ fprintf(stderr, "Invalid character: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
}

