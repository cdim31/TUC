%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "HelperFiles/cgen.h"
#include "myanalyzer.tab.h"  

int line_num = 1;
// Macro table to store @defmacro substitutions
typedef struct Macro {
    char *name;
    char *replacement;
    struct Macro *next;
} Macro;

Macro *macro_table = NULL;

void add_macro(const char *name, const char *replacement) {
    Macro *m = (Macro *)malloc(sizeof(Macro));
    m->name = strdup(name);
    m->replacement = strdup(replacement);
    m->next = macro_table;
    macro_table = m;
}

const char *find_macro(const char *name) {
    Macro *m = macro_table;
    while (m) {
        if (strcmp(m->name, name) == 0) return m->replacement;
        m = m->next;
    }
    return NULL;
}

%}
/* Track line numbers */
%option yylineno   
/* Disable yywrap */
%option noyywrap    

/* ********* definitions ********* */
%x MACRO_DEF
%x REPLACEMENT

DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER   "0"|[1-9]{DIGIT}*
FLOAT {INTEGER}+\.{DIGIT}+([eE][+-]?{INTEGER}+)?
STRING      \"([^\\\n"]|\\[nrt"\\])*\"

%x inline_comment

%%
  /* ----- Keywords ----- */
"integer"       { return KEYWORD_INT; }
"scalar"        { return KEYWORD_SCALAR; }
"str"           { return KEYWORD_STR; }
"bool"          { return KEYWORD_BOOL; }
"True"          { return KEYWORD_TRUE; }  
"False"         { return KEYWORD_FALSE; }
"const"         { return KEYWORD_CONST; }
"if"            { return KEYWORD_IF; }      
"else"          { return KEYWORD_ELSE; }  
"endif"         { return KEYWORD_ENDIF; }
"for"           { return KEYWORD_FOR; }
"in"            { return KEYWORD_IN; }
"endfor"        { return KEYWORD_ENDFOR; }
"while"         { return KEYWORD_WHILE; }
"endwhile"      { return KEYWORD_ENDWHILE; }
"break"         { return KEYWORD_BREAK; }    
"continue"      { return KEYWORD_CONTINUE; }  
"not"           { return KEYWORD_NOT; }
"and"           { return KEYWORD_AND; }  
"or"            { return KEYWORD_OR; }
"def"           { return KEYWORD_DEF; }
"enddef"        { return KEYWORD_ENDDEF; }
"main"          { return KEYWORD_MAIN; }
"return"        { return KEYWORD_RETURN; }
"comp"          { return KEYWORD_COMP; }  
"endcomp"       { return KEYWORD_ENDCOMP; } 
"of"            { return KEYWORD_OF; }

  /* ----- Constants ----- */
{INTEGER}     { yylval.str = strdup(yytext); return INTEGER; }
{FLOAT}   { yylval.str = strdup(yytext); return FLOAT; }
{STRING}        { yylval.str = strdup(yytext); return STRING; }

  /* ----- Operators and Delimiters ----- */
"+"         { return PLUS_OP; }
"-"         { return MINUS_OP; }
"*"         { return MULT_OP; }
"/"         { return DIV_OP; }
"%"         { return MOD_OP; }
"**"        { return POWER_OP; }
"=="        { return EQUAL_OP; }
"!="        { return NEQ_OP; }
"<"         { return LESS_OP; }
"<="        { return LEQ_OP; }
">"         { return GREATER_OP; }
">="        { return GEQ_OP; }

"="         { return ASSIGN_OP; }
"+="        { return PLUS_ASSIGN_OP; }
"-="        { return MINUS_ASSIGN_OP; }
"*="        { return MULT_ASSIGN_OP; }
"/="        { return DIV_ASSIGN_OP; }
"%="        { return MOD_ASSIGN_OP; }
":="        { return COLON_ASSIGN_OP; }

";"         { return SEMICOLON; } 
"("         { return L_PAREN; }
")"         { return R_PAREN; }
","         { return COMMA; }
"["         { return L_BRACKET; }
"]"         { return R_BRACKET; }
"{"         { return L_CURLY_BRACKET; }
"}"         { return R_CURLY_BRACKET; }
":"         { return COLON; }
"."         { return DOT; }

"#"         { return HASH; }
"->"        { return ARROW; } 

"readStr"      { return F_READSTR; }
"readInteger"  { return F_READINT; }
"readScalar"   { return F_READSC; }
"writeStr"     { return F_WRITESTR; }
"writeInteger" { return F_WRITEINT; }
"writeScalar"  { return F_WRITESC; }
"write"        { return F_WRITE; }

  /* ----- Handle Macros (@defmacro) ----- */
"@defmacro"    { BEGIN(MACRO_DEF); }

<MACRO_DEF>{
    [ \t]+        
    /* Ignore whitespace */
    {ID}[^\n]*          {
        char *name = strdup(yytext);
        char *repl = yytext + yyleng;

        sscanf(yytext, "%127s", name);

        char *start = strstr(yytext, name);
        if (start) {
            start += strlen(name);
            // Trim leading whitespace in replacement
            while (*start == ' ' || *start == '\t') start++;
            repl = strdup(start);
            add_macro(name, repl);
            free(repl);
        }
        BEGIN(INITIAL);
    }
    \n           { BEGIN(INITIAL); }  
    /* Reset on error */
}

  /* ----- Identifiers (with macro substitution) ----- */
{ID}            {
    const char *replacement = find_macro(yytext);
    if (replacement) {
        // Unput in reverse order so the lexer reads it correctly
        for (int i = strlen(replacement) - 1; i >= 0; i--) {
            unput(replacement[i]);
        }
    } else {
        //printf("token IDENTIFIER: %s\n", yytext);
        yylval.str = strdup(yytext);
        return IDENTIFIER;
    }
}

 /* Skip Space, tabs, or carriage returns */
[ \t\r]+                

 /*Skip line feed, but increase counter*/
\n          {++line_num;}

 /*Unrecognized chars*/
.           { printf("Unrecognized token %s in line %d\n", yytext, line_num); exit(1); }


 /*  For Inline comments, ignore anything that's not a \n */
"--"                        BEGIN(inline_comment);
<inline_comment>[^\n]*      
<inline_comment>\n          {++line_num; BEGIN(INITIAL);}

<<EOF>>      { return EOF; }
%%
