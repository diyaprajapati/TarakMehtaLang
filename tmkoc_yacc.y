%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylex();
extern int yyerror(const char *msg);
extern int line_num; // Line number from lexer
extern int column_num; // Column number from lexer

typedef union {
    int num;
    char* str;
} SymValue;

SymValue sym[26];

void free_symbol_table() {
    for (int i = 0; i < 26; i++) {
        if (sym[i].str) {
            free(sym[i].str);
            sym[i].str = NULL;
        }
    }
}

%}

%union {
    int num;
    char* str;
}

%token <num> NUM
%token <str> IDENTIFIER STRING_LITERAL TAPU_INT TAPU_STRING
%token EQ SEMICOLON COMMA PRINT OPEN_PAREN CLOSE_PAREN OPEN_BRACE CLOSE_BRACE PLUS MINUS TIMES DIVIDE GOKULDHAM
%token EQUAL NE LT LE GT GE
%token NAHANE_JA

%type <num> expression

/* Define precedence and associativity to resolve shift/reduce conflicts */
%left PLUS MINUS    /* lowest precedence */
%left TIMES DIVIDE  /* higher precedence */
%left NEG           /* negation--highest precedence */

%%

program: block
       ;

block: GOKULDHAM OPEN_BRACE {
          printf("Good Morning Gokuldham!\n");  // Print welcome message
      }
      statement_list CLOSE_BRACE;

statement_list: statement
              | statement_list statement
              ;

statement: declaration
         | assignment
         | print_statement
         | nahane_ja_statement
         ;

expression: NUM { $$ = $1; }
          | IDENTIFIER { 
                int index = $1[0] - 'a';
                if (index < 0 || index >= 26) {
                    yyerror("Invalid variable name");
                    exit(1);
                }
                $$ = sym[index].num; 
            }
          | expression PLUS expression { $$ = $1 + $3; }
          | expression MINUS expression { $$ = $1 - $3; }
          | expression TIMES expression { $$ = $1 * $3; }
          | expression DIVIDE expression { 
                if ($3 != 0) $$ = $1 / $3; 
                else {
                    yyerror("Division by zero");
                    $$ = 0; // Provide a default value to continue parsing
                }
            }
          | MINUS expression %prec NEG { $$ = -$2; }  /* Unary minus */
          | OPEN_PAREN expression CLOSE_PAREN { $$ = $2; }
          ;

declaration: TAPU_INT IDENTIFIER EQ expression SEMICOLON { 
                 int index = ((char*)$2)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     yyerror("Invalid variable name\n");
                     exit(1);
                 }
                 sym[index].num = $4; 
             }
           | TAPU_STRING IDENTIFIER EQ STRING_LITERAL SEMICOLON { 
                 int index = ((char*)$2)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     yyerror("Invalid variable name\n");
                     exit(1);
                 }
                 sym[index].str = strdup($4); 
             }
           ;

assignment: IDENTIFIER EQ expression SEMICOLON {
                int index = ((char*)$1)[0] - 'a';
                if (index < 0 || index >= 26) {
                    yyerror("Invalid variable name\n");
                    exit(1);
                }
                sym[index].num = $3;
            }
          ;

print_statement: PRINT OPEN_PAREN TAPU_INT COMMA IDENTIFIER CLOSE_PAREN SEMICOLON {
                 int index = ((char*)$5)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     yyerror("Invalid variable name\n");
                     exit(1);
                 }
                 if (sym[index].num)
                     printf("Bhidu, %s ka bhav %d hai!\n", $5, sym[index].num);
                 else
                     printf("NULL\n");
               }
               | PRINT OPEN_PAREN TAPU_STRING COMMA IDENTIFIER CLOSE_PAREN SEMICOLON {
                 int index = ((char*)$5)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     yyerror("Invalid variable name\n");
                     exit(1);
                 }
                 if (sym[index].str)
                     printf("Bhidu, %s ka bhav '%s' hai!\n", $5, sym[index].str);
                 else
                     printf("NULL\n");
               }
               ;

nahane_ja_statement: NAHANE_JA SEMICOLON {  
                    printf("Tu abhi bhi yaha he, nahane ja nahane ja\n");
                }
                ;

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Error at line %d, column %d: %s\n", line_num, column_num, msg);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening file");
        return 1;
    }

    yyparse();

    fclose(yyin);
    free_symbol_table(); // Free allocated memory

    printf("Gokuldham ka din shubh rahe!\n");

    return 0;
}