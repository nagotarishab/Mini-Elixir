%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* TAC (Three Address Code) support */
int temp_count = 0;
int label_count = 0;

char* current_start_label;
char* current_end_label;

char* new_temp() {
    char* t = (char*)malloc(16);
    sprintf(t, "t%d", temp_count++);
    return t;
}

char* new_label() {
    char* l = (char*)malloc(16);
    sprintf(l, "L%d", label_count++);
    return l;
}

void emit(const char* code) {
    printf("%s\n", code);
}

void emit3(const char* res, const char* a, const char* op, const char* b) {
    char buf[256];
    sprintf(buf, "%s = %s %s %s", res, a, op, b);
    emit(buf);
}

void emit2(const char* res, const char* op, const char* a) {
    char buf[256];
    sprintf(buf, "%s = %s %s", res, op, a);
    emit(buf);
}

void emit_assign(const char* lhs, const char* rhs) {
    char buf[256];
    sprintf(buf, "%s = %s", lhs, rhs);
    emit(buf);
}

void emit_goto(const char* label) {
    char buf[64];
    sprintf(buf, "goto %s", label);
    emit(buf);
}

void emit_iffalse(const char* cond, const char* label) {
    char buf[128];
    sprintf(buf, "ifFalse %s goto %s", cond, label);
    emit(buf);
}

void emit_label(const char* label) {
    char buf[64];
    sprintf(buf, "%s:", label);
    emit(buf);
}

extern int yylex();
void yyerror(const char* s);
%}

%union {
    char* str;
}

%token <str> IDENTIFIER NUMBER
%token IF DO END WHILE AND OR NOT TRUE FALSE
%token EQ NEQ LT GT LE GE
%token PLUS MINUS MULT DIV ASSIGN

%type <str> expr or_expr and_expr rel_expr add_expr mul_expr unary_expr primary

%start program

%%

program
    : stmt_list
    ;

stmt_list
    : stmt
    | stmt_list stmt
    ;

stmt
    : IDENTIFIER ASSIGN expr
        {
            emit_assign($1, $3);
            free($1); free($3);
        }
    | IF expr DO
    {
        current_end_label = new_label();
        emit_iffalse($2, current_end_label);
        free($2);
    }
  stmt_list END
    {
        emit_label(current_end_label);
    }
    | WHILE
    {
        current_start_label = new_label();
        emit_label(current_start_label);
    }
  expr DO
    {
        current_end_label = new_label();
        emit_iffalse($3, current_end_label);
        free($3);
    }
  stmt_list END
    {
        emit_goto(current_start_label);
        emit_label(current_end_label);
    }

expr
    : or_expr   { $$ = $1; }
    ;

or_expr
    : or_expr OR and_expr
        {
            char* t = new_temp();
            emit3(t, $1, "||", $3);
            free($1); free($3);
            $$ = t;
        }
    | and_expr  { $$ = $1; }
    ;

and_expr
    : and_expr AND rel_expr
        {
            char* t = new_temp();
            emit3(t, $1, "&&", $3);
            free($1); free($3);
            $$ = t;
        }
    | rel_expr  { $$ = $1; }
    ;

rel_expr
    : rel_expr EQ  add_expr { char* t = new_temp(); emit3(t,$1,"==",$3); free($1);free($3); $$=t; }
    | rel_expr NEQ add_expr { char* t = new_temp(); emit3(t,$1,"!=",$3); free($1);free($3); $$=t; }
    | rel_expr LT  add_expr { char* t = new_temp(); emit3(t,$1,"<", $3); free($1);free($3); $$=t; }
    | rel_expr GT  add_expr { char* t = new_temp(); emit3(t,$1,">", $3); free($1);free($3); $$=t; }
    | rel_expr LE  add_expr { char* t = new_temp(); emit3(t,$1,"<=",$3); free($1);free($3); $$=t; }
    | rel_expr GE  add_expr { char* t = new_temp(); emit3(t,$1,">=",$3); free($1);free($3); $$=t; }
    | add_expr  { $$ = $1; }
    ;

add_expr
    : add_expr PLUS  mul_expr
        {
            char* t = new_temp();
            emit3(t, $1, "+", $3);
            free($1); free($3);
            $$ = t;
        }
    | add_expr MINUS mul_expr
        {
            char* t = new_temp();
            emit3(t, $1, "-", $3);
            free($1); free($3);
            $$ = t;
        }
    | mul_expr  { $$ = $1; }
    ;

mul_expr
    : mul_expr MULT  unary_expr
        {
            char* t = new_temp();
            emit3(t, $1, "*", $3);
            free($1); free($3);
            $$ = t;
        }
    | mul_expr DIV   unary_expr
        {
            char* t = new_temp();
            emit3(t, $1, "/", $3);
            free($1); free($3);
            $$ = t;
        }
    | unary_expr  { $$ = $1; }
    ;

unary_expr
    : NOT unary_expr
        {
            char* t = new_temp();
            emit2(t, "not", $2);
            free($2);
            $$ = t;
        }
    | primary   { $$ = $1; }
    ;

primary
    : IDENTIFIER    { $$ = $1; }
    | NUMBER        { $$ = $1; }
    | TRUE          { $$ = strdup("true"); }
    | FALSE         { $$ = strdup("false"); }
    | '(' expr ')'  { $$ = $2; }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main() {
    printf("=== Three Address Code Output ===\n");
    yyparse();
    return 0;
}
