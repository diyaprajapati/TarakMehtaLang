/* tmkoc_yacc.y */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylex();
extern int yyerror(const char *msg);
extern int line_num; // Line number from lexer
extern int column_num; // Column number from lexer

// Error type enumeration
typedef enum {
    ERROR_LEXICAL,
    ERROR_SYNTAX,
    ERROR_SEMANTIC,
    ERROR_RUNTIME
} ErrorType;

// Function to print detailed error messages
void print_error(ErrorType type, const char *msg) {
    switch(type) {
        case ERROR_LEXICAL:
            fprintf(stderr, "Lexical Error at line %d, column %d: %s\n", line_num, column_num, msg);
            break;
        case ERROR_SYNTAX:
            fprintf(stderr, "Syntax Error at line %d, column %d: %s\n", line_num, column_num, msg);
            break;
        case ERROR_SEMANTIC:
            fprintf(stderr, "Semantic Error at line %d, column %d: %s\n", line_num, column_num, msg);
            break;
        case ERROR_RUNTIME:
            fprintf(stderr, "Runtime Error at line %d, column %d: %s\n", line_num, column_num, msg);
            break;
    }
}

typedef union {
    int num;
    char* str;
} SymValue;

SymValue sym[26];
int initialized[26] = {0}; // Track if variables are initialized

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
                    print_error(ERROR_SEMANTIC, "Invalid variable name");
                    exit(1);
                }
                if (!initialized[index]) {
                    print_error(ERROR_SEMANTIC, "Variable used before initialization");
                    $$ = 0; // Provide default value to continue
                } else {
                    $$ = sym[index].num;
                }
            }
          | expression PLUS expression { $$ = $1 + $3; }
          | expression MINUS expression { $$ = $1 - $3; }
          | expression TIMES expression { $$ = $1 * $3; }
          | expression DIVIDE expression { 
                if ($3 != 0) {
                    $$ = $1 / $3;
                } else {
                    print_error(ERROR_RUNTIME, "Division by zero");
                    $$ = 0; // Provide a default value to continue parsing
                }
            }
          | MINUS expression %prec NEG { $$ = -$2; }  /* Unary minus */
          | OPEN_PAREN expression CLOSE_PAREN { $$ = $2; }
          ;

declaration: TAPU_INT IDENTIFIER EQ expression SEMICOLON { 
                 int index = ((char*)$2)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     print_error(ERROR_SEMANTIC, "Invalid variable name");
                     exit(1);
                 }
                 sym[index].num = $4;
                 initialized[index] = 1; 
             }
           | TAPU_STRING IDENTIFIER EQ STRING_LITERAL SEMICOLON { 
                 int index = ((char*)$2)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     print_error(ERROR_SEMANTIC, "Invalid variable name");
                     exit(1);
                 }
                 if (sym[index].str) {
                     free(sym[index].str); // Free any existing string
                 }
                 sym[index].str = strdup($4);
                 initialized[index] = 1;
             }
           ;

assignment: IDENTIFIER EQ expression SEMICOLON {
                int index = ((char*)$1)[0] - 'a';
                if (index < 0 || index >= 26) {
                    print_error(ERROR_SEMANTIC, "Invalid variable name");
                    exit(1);
                }
                // Check if variable was declared with proper type
                if (!initialized[index]) {
                    print_error(ERROR_SEMANTIC, "Assignment to undeclared variable");
                    exit(1);
                }
                sym[index].num = $3;
            }
          ;

print_statement: PRINT OPEN_PAREN TAPU_INT COMMA IDENTIFIER CLOSE_PAREN SEMICOLON {
                 int index = ((char*)$5)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     print_error(ERROR_SEMANTIC, "Invalid variable name");
                     exit(1);
                 }
                 if (!initialized[index]) {
                     print_error(ERROR_SEMANTIC, "Attempt to print uninitialized variable");
                     printf("NULL\n");
                 } else {
                     printf("Bhidu, %s ka bhav %d hai!\n", $5, sym[index].num);
                 }
               }
               | PRINT OPEN_PAREN TAPU_STRING COMMA IDENTIFIER CLOSE_PAREN SEMICOLON {
                 int index = ((char*)$5)[0] - 'a';
                 if (index < 0 || index >= 26) {
                     print_error(ERROR_SEMANTIC, "Invalid variable name");
                     exit(1);
                 }
                 if (!initialized[index] || !sym[index].str) {
                     print_error(ERROR_SEMANTIC, "Attempt to print uninitialized string");
                     printf("NULL\n");
                 } else {
                     printf("Bhidu, %s ka bhav '%s' hai!\n", $5, sym[index].str);
                 }
               }
               ;

nahane_ja_statement: NAHANE_JA SEMICOLON {  
                    printf("Tu abhi bhi yaha he, nahane ja nahane ja\n");
                }
                ;

%%

int yyerror(const char *msg) {
    print_error(ERROR_SYNTAX, msg);
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