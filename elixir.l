%{
#include "elixir.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

"if"                    { return IF; }
"do"                    { return DO; }
"end"                   { return END; }
"while"                 { return WHILE; }
"and"                   { return AND; }
"or"                    { return OR; }
"not"                   { return NOT; }
"true"                  { return TRUE; }
"false"                 { return FALSE; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
"<="                    { return LE; }
">="                    { return GE; }
"<"                     { return LT; }
">"                     { return GT; }
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return MULT; }
"/"                     { return DIV; }
"="                     { return ASSIGN; }
[0-9]+                  { yylval.str = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[ \t\n\r]+              ;
"#"[^\n]*               ;   /* single-line comments */
.                       { fprintf(stderr, "Lexical Error: unknown character '%s'\n", yytext); }

%%

int yywrap() {
    return 1;
}
