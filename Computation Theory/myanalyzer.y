
%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "HelperFiles/cgen.h"
  #include "HelperFiles/lambdalib.h"
  extern int yylex(void); /* Extern means that yylex() line_num is defined elsewhere (in FLex)*/
  extern int line_num;
%}

%define parse.error verbose /* To give error message in details */

 /* Semantic value declaration */
 /* Union type that cointains the different types of my tokens, rules, in this case only strings are returned. */
%union {
    char *str;
    struct {
        char *ptr;
        char *def;
    } method_t;
    struct {
        int is_field;
        union {
            char *field;
            struct {
                char *ptr;
                char *def;
            } method;
        } u;
    } element_t;
    struct {
        char *fields;
        char *method_ptrs;
        char *method_defs;
        char *ctor_inits;
    } comp_body_t;
}
  
 /* Token declarations (terminal symbols)*/
%token KEYWORD_INT   
%token KEYWORD_SCALAR  
%token KEYWORD_STR
%token KEYWORD_BOOL
%token KEYWORD_TRUE  
%token KEYWORD_FALSE 
%token KEYWORD_CONST  
%token KEYWORD_IF  
%token KEYWORD_ELSE   
%token KEYWORD_ENDIF
%token KEYWORD_FOR  
%token KEYWORD_IN  
%token KEYWORD_ENDFOR  
%token KEYWORD_WHILE
%token KEYWORD_ENDWHILE
%token KEYWORD_BREAK
%token KEYWORD_CONTINUE 
%token KEYWORD_NOT   
%token KEYWORD_AND
%token KEYWORD_OR  
%token KEYWORD_DEF  
%token KEYWORD_ENDDEF  
%token KEYWORD_MAIN
%token KEYWORD_RETURN
%token KEYWORD_COMP
%token KEYWORD_ENDCOMP  
%token KEYWORD_OF 
%token KEYWORD_SELF 

%token PLUS_OP
%token MINUS_OP  
%token MULT_OP 
%token DIV_OP  
%token MOD_OP
%token POWER_OP
%token EQUAL_OP
%token NEQ_OP  
%token LESS_OP  
%token LEQ_OP  
%token GREATER_OP
%token GREQ_OP

%token ASSIGN_OP
%token PLUS_ASSIGN_OP  
%token MINUS_ASSIGN_OP  
%token MULT_ASSIGN_OP  
%token DIV_ASSIGN_OP
%token MOD_ASSIGN_OP
%token COLON_ASSIGN_OP

%token SEMICOLON   
%token L_PAREN  
%token R_PAREN  
%token COMMA
%token L_BRACKET
%token R_BRACKET
%token L_CURLY_BRACKET  
%token R_CURLY_BRACKET  
%token COLON  
%token DOT

%token HASH
%token ARROW

%token F_READSTR 
%token F_READINT  
%token F_READSC  
%token F_WRITESTR
%token F_WRITEINT
%token F_WRITESC
%token F_WRITE


 /* Declare associativity (from down to top) */
%left COMMA /* warning from the parser,so i had to put it */
%left ASSIGN_OP PLUS_ASSIGN_OP MINUS_ASSIGN_OP MULT_ASSIGN_OP DIV_ASSIGN_OP MOD_ASSIGN_OP COLON_ASSIGN_OP
%left KEYWORD_OR
%left KEYWORD_AND
%right KEYWORD_NOT 
%left EQUAL_OP NEQ_OP
%left LESS_OP LEQ_OP GREATER_OP GEQ_OP
%left PLUS_OP MINUS_OP
%left MULT_OP DIV_OP MOD_OP
%right UPLUS UMINUS /* unary operators */
%right POWER_OP
%left DOT L_PAREN R_PAREN L_BRACKET R_BRACKET

 /* Tokens with values */
%token <str> IDENTIFIER
%token <str> INTEGER
%token <str> FLOAT           
%token <str> STRING



 /* Non-terminal symbols */


/* programs input - starting the program*/
%start input
/* programs body */

%type <str> body
%type <str> bodies

/* Data types */
%type <str> data_type

/* variables */
%type <str> identifiers
%type <str> arrays
%type <str> array_ref
//%type <str> arrays_decl
%type <str> variables
%type <str> hash_identifiers
%type <str> func_hash_identifiers
%type <str> hash_identifier_chain
//%type <str> hash_identifier_list
%type <str> hash_identifier
//%type <str> hash_args
%type <str> hash_arrays
%type <str> hash_variables
%type <str> function_variables

/* constants */
%type <str> constants

/* complex types definition */
%type <str> comp_definition comp_field
%type <method_t> comp_method
%type <element_t> comp_element
%type <comp_body_t> comp_body
//%type <str> assignment lvalue hash_lvalue array_access hash_array_access 
//%type <str> hash_arg_list

/* expressions */
%type <str> expression
//%type <str> arithmetic_expression

/* statements */
%type <str> statements_body
%type <str> statement
%type <str> value
%type <str> expr

/* if statement */
%type <str> if_statement
%type <str> opt_else

/* for statement */
%type <str> for_statement

/* while statement */
%type <str> while_statement

/* break statement */
%type <str> break_statement

/* continue statement */
%type <str> continue_statement

/* return statement */
%type <str> return_statement

 /* function call */
%type <str> function_call
%type <str> function_call_expr
%type <str> arg_list

/* empty statement */
%type <str> empty_statement

/* compact array creation over integer */
%type <str> compact_array_integer
%type <str> compact_array_array

/* main */
%type <str> main_func

/* function definition */
%type <str> function_definition
%type <str> function_parameters
%type <str> func_var_constants
%type <str> function_param_list
%type <str> function_body

%type <str> assign_expr
%type <str> or_expr
%type <str> and_expr
%type <str> not_expr
%type <str> comp_expr
%type <str> add_expr
%type <str> mult_expr
%type <str> pow_expr
%type <str> unary_expr
%type <str> primary_expr

%% 
 /* Grammar rules and actions */

 /* The first rule is the starting point of the parser. */
 /* If the input is empty or there is a program body with no
  errors print the body ($2) */
input:  
  %empty 
  | bodies { 
    if (yyerror_count == 0) {
/*	
COMMENT BECAUSE OF THE NEW MAKEFILE
  FILE *fp = fopen("my_output.c", "w+");
          fputs("#include <stdio.h>\n", fp);
          fputs("#include <stdlib.h>\n", fp);
          fputs(c_prologue, fp);  // from cgen.h
          fputs($1, fp);          // this is the C code from the parsed body
          fputs("\n\n", fp);
          fclose(fp);
*/
          /* simply write the C to stdout */
          printf("#include <stdio.h>\n");
          printf("#include <stdlib.h>\n");
          printf("#include <math.h>\n");
/*          printf("void writeStr(const char* str) { printf(\"%%s\", str); }\n");
          printf("int readInteger() {\n");
	  printf("    int value;\n");
	  printf("    scanf(\"%%d\", &value);\n");
	  printf("    return value;\n");
	  printf("}\n\n");
          printf("void writeInteger(int value) {\n");
	  printf("    printf(\"%%d\", value);\n");
	  printf("}\n\n");
	  printf("void writeScalar(double value) {\n");
          printf("    printf(\"%%f\", value);\n");
          printf("}\n\n");
*/
          //printf("#include <simpletext.h>\n");
          // Comment out lambdalib to see if files are running correctly in C
          printf("#include \"../HelperFiles/lambdalib.h\"\n");
          printf("%s\n\n", $1);

    }

  }; 

bodies:
  body { $$ = template("%s", $1); }
  | body bodies { $$ = template("%s%s", $1, $2); }

body:
  variables 
  | constants 
  | comp_definition 
  | main_func 
  | function_definition 
;

 /*-------------Variable Data Type-------------*/
 /* - integer, scalar, str, bool, comp 
    - Complex types e.g circle        */

 data_type:
  KEYWORD_SCALAR { $$ = "double"; }
  | KEYWORD_INT { $$ = "int"; }
  | KEYWORD_STR { $$ = "char*"; }
  | KEYWORD_BOOL { $$ = "int"; }
  | IDENTIFIER { $$ = $1; } /* complex type name */
;
 /*-------------Variables-------------*/
 /* - i,john,...,mkey: type; --> type i;
    - grades[5]: type;       --> type grades[5];
                        */  
identifiers:
  identifiers COMMA IDENTIFIER { $$ = template("%s, %s", $1, $3); }
  | IDENTIFIER { $$ = $1; }
;
 /*for complex types*/
hash_identifier:
  HASH IDENTIFIER { 
    $$ = template("%s", $2); 
  }
;

hash_identifier_chain:
    hash_identifier { $$ = $1; }
    | hash_identifier_chain DOT hash_identifier { $$ = template("%s.%s", $1, $3); }
;

hash_identifiers:
  hash_identifier_chain { $$ = $1; }
  | hash_identifiers COMMA hash_identifier_chain { $$ = template("%s,%s", $1, $3); }
;

func_hash_identifiers:
  hash_identifier_chain { $$ = $1; }
;

hash_arrays:
  HASH array_ref { $$ = $2; }
;

array_ref:
  IDENTIFIER L_BRACKET expression R_BRACKET { $$ = template("%s[%s]", $1, $3); }
  | IDENTIFIER L_BRACKET R_BRACKET { $$ = template("%s[]", $1); }
;

arrays:
  array_ref { $$ = template("%s", $1); }
  | array_ref COMMA arrays { $$ = template("%s, %s", $1, $3); }
;

variables:
  identifiers COLON data_type SEMICOLON { 
     if ($3 != "int" && $3 != "double" && $3 != "char*"){
	$$ = template("%s %s = ctor_%s;\n", $3, $1, $3);
     }
     else{
     $$ = template("%s %s;\n", $3, $1); 
    }
  }
  | arrays COLON data_type SEMICOLON { $$ = template("%s %s;\n", $3, $1); }
;
 /*Without semicolon, for function paraemeters*/
function_variables:
  identifiers COLON data_type { $$ = template("%s %s", $3, $1); }
  | array_ref COLON data_type { $$ = template("%s %s", $3, $1); }
  | hash_identifiers COLON data_type { $$ = template("self->%s %s", $3, $1); }
;

hash_variables:
 hash_identifiers COLON data_type SEMICOLON { 
 	if (strcmp($3, "char*") == 0) {
      // Prefix * to each identifier in $1
      char* result = malloc(strlen($1) * 2 + 1);  // Enough space for stars and commas
      result[0] = '\0';

      char* token = strtok($1, ",");
      while (token) {
        while (*token == ' ') token++;  // Trim leading spaces
        strcat(result, "*");
        strcat(result, token);

        token = strtok(NULL, ",");
        if (token) strcat(result, ", ");
      }

      $$ = template("char %s;\n", result);
      free(result);
    } else {
      $$ = template("%s %s;\n", $3, $1);
    }
   }
  | hash_arrays COLON data_type SEMICOLON { $$ = template("%s %s;\n", $3, $1) ; }
;

 /*-------------Constants-------------*/
 /* const pi = 3.14: type; --> const type pi = 3.14; */
constants:
  KEYWORD_CONST IDENTIFIER ASSIGN_OP INTEGER COLON data_type SEMICOLON
  { 
    $$ = template("const %s %s = %s;\n", $6, $2, $4);
  } 
  | KEYWORD_CONST IDENTIFIER ASSIGN_OP FLOAT COLON data_type SEMICOLON
  { 
    $$ = template("const %s %s = %s;\n", $6, $2, $4);
  }
  | KEYWORD_CONST IDENTIFIER ASSIGN_OP STRING COLON data_type SEMICOLON
  { 
    $$ = template("const %s %s = %s;\n", $6, $2, $4);
  }
  /*-------------Complex Types Deffinition-------------*/
  /*
    comp Human:                 typedef struct Human{
      #age: integer;                     int age;  
      #name: string;  ==>                char* name;
    endcomp;                    } Human;

    Also implemented functions inside the complex type
  */

/* COMPLEX TYPE DEFINITION RULE
   Handles the overall structure of a component (struct + methods) */
comp_definition:
  KEYWORD_COMP IDENTIFIER COLON comp_body KEYWORD_ENDCOMP SEMICOLON
  {
    char *struct_name = $2;  // Get component name from second token
    // Destructure comp_body parts ($4):
    char *fields = $4.fields;        // Struct field declarations
    char *method_ptrs = $4.method_ptrs;  // Method function pointers
    char *method_defs = $4.method_defs;  // Method implementations
    char *ctor_inits = $4.ctor_inits;    // Constructor initializer list
    char *temp;

    if (ctor_inits[0]) {  // If there are methods to initialize
      // Generate full component with methods and constructor
      temp = template(
          "#define SELF struct %s *self\n"  // Macro for method self parameter
          "typedef struct %s {\n"          // Struct definition start
          "%s"  // Fields insertion point
          "%s"  // Method pointers insertion
          "} %s;\n\n"                     // Struct type definition
          "%s"  // Method implementations
          "const %s ctor_%s = {%s};\n"    // Constructor initialization
          "#undef SELF\n",               // Cleanup macro
          struct_name, struct_name, fields, method_ptrs, struct_name,
          method_defs,
          struct_name, struct_name, ctor_inits
      );
    } else {  // Component with only fields
      temp = template(
          "typedef struct %s {\n"  // Simple struct definition
          "%s"  // Fields insertion
          "} %s;\n\n",
          struct_name, fields, struct_name
      );
    }
    $$ = temp;    // Set final output
    
    // Cleanup allocated memory
    free(struct_name);
    free(fields);
    free(method_ptrs);
    free(method_defs);
    free(ctor_inits);
  }
;

/* COMPLEX TYPE BODY RULES
   Handles accumulation of fields and methods within component */
comp_body:
  comp_element  // Single element case
  {
    if ($1.is_field) {
      // Handle field declaration
      $$.fields = $1.u.field;
      $$.method_ptrs = strdup("");  // Initialize empty method parts
      $$.method_defs = strdup("");
      $$.ctor_inits = strdup("");
    } else {
      // Handle method declaration
      $$.fields = strdup("");
      $$.method_ptrs = $1.u.method.ptr;
      $$.method_defs = $1.u.method.def;
      // Extract method name from pointer declaration (e.g., "(*print)" -> "print")
      char *method_name = strstr($1.u.method.ptr, "(*") + 2;  // Find method name start
      char *end = strchr(method_name, ')');
      if (end) {
        *end = '\0';  // Temporarily null-terminate for copying
        $$.ctor_inits = template(".%s = %s", method_name, method_name);  // Create initializer
        *end = ')';   // Restore original character
      } else {
        $$.ctor_inits = strdup("");
      }
    }
  }
  | comp_body comp_element  // Recursive case for multiple elements
  {
    if ($2.is_field) {
      // Concatenate field declarations
      char *new_fields = template("%s%s", $1.fields, $2.u.field);
      $$.fields = new_fields;
      // Carry forward method parts unchanged
      $$.method_ptrs = $1.method_ptrs;
      $$.method_defs = $1.method_defs;
      $$.ctor_inits = $1.ctor_inits;
      // Cleanup temporary values
      free($1.fields);
      free($2.u.field);
    } else {
      // Concatenate method components
      char *new_method_ptrs = template("%s%s", $1.method_ptrs, $2.u.method.ptr);
      char *new_method_defs = template("%s%s", $1.method_defs, $2.u.method.def);
      
      // Process method name for initializer list
      char *method_name = strstr($2.u.method.ptr, "(*") + 2;
      char *end = strchr(method_name, ')');
      char *new_ctor_inits = $1.ctor_inits;
      
      if (end) {
        *end = '\0';  // Temporarily terminate method name
        // Build comma-separated initializer list
        if ($1.ctor_inits[0]) {
          new_ctor_inits = template("%s, .%s = %s", $1.ctor_inits, method_name, method_name);
        } else {
          new_ctor_inits = template(".%s = %s", method_name, method_name);
        }
        *end = ')';  // Restore original character
      }
      
      // Update component parts
      $$.fields = $1.fields;
      $$.method_ptrs = new_method_ptrs;
      $$.method_defs = new_method_defs;
      $$.ctor_inits = new_ctor_inits;
      
      // Cleanup old values
      free($1.method_ptrs);
      free($1.method_defs);
      free($1.ctor_inits);
      free($2.u.method.ptr);
      free($2.u.method.def);
    }
  }
;

/* COMPLEX TYPE ELEMENT DISCRIMINATION
   Determines if element is a field or method */
comp_element:
  comp_field  // Field case
  {
    $$.is_field = 1;  // Set field flag
    $$.u.field = $1;  // Store field string
  }
  | comp_method  // Method case
  {
    $$.is_field = 0;  // Clear field flag
    $$.u.method.ptr = $1.ptr;  // Store method pointer declaration
    $$.u.method.def = $1.def;  // Store method implementation
  }
;

/* FIELD DEFINITION HANDLING */
comp_field:
  hash_variables  // Variables declared with # (e.g., #int x)
  {
    $$ = template("    %s", $1);  // Add indentation for struct field
    free($1);  // Free original variable declaration
  }
;

/* METHOD DEFINITION HANDLING */
comp_method:
  // Method with return type
  KEYWORD_DEF IDENTIFIER L_PAREN function_parameters R_PAREN ARROW data_type COLON function_body KEYWORD_ENDDEF SEMICOLON
  {
    // Create method pointer declaration (e.g., "int (*print)(SELF);")
    $$.ptr = template("    %s (*%s)(SELF%s%s);\n", $7, $2, $4[0] ? "," : "", $4);
    // Create method implementation
    $$.def = template(
        "%s %s(SELF%s%s) {\n"  // Function signature
        "%s"                   // Function body
        "}\n\n",               // Closing
        $7, $2, $4[0] ? "," : "", $4, $9
    );
  }
  // Void method (no return type)
  | KEYWORD_DEF IDENTIFIER L_PAREN function_parameters R_PAREN COLON function_body KEYWORD_ENDDEF SEMICOLON
  {
    $$.ptr = template("    void (*%s)(SELF%s%s);\n", $2, $4[0] ? "," : "", $4);
    $$.def = template(
        "void %s(SELF%s%s) {\n"
        "%s"
        "}\n\n",
        $2, $4[0] ? "," : "", $4, $7
    );
  }
;
  /* Expressions */
  /* Declare all expressions */

expression:
    assign_expr { $$ = $1; }
;

assign_expr:
    or_expr { $$ = $1; }
    | assign_expr ASSIGN_OP or_expr { $$ = template("%s = %s", $1, $3); }
    | assign_expr PLUS_ASSIGN_OP or_expr { $$ = template("%s += %s", $1, $3); }
    | assign_expr MINUS_ASSIGN_OP or_expr { $$ = template("%s -= %s", $1, $3); }
    | assign_expr MULT_ASSIGN_OP or_expr { $$ = template("%s *= %s", $1, $3); }
    | assign_expr DIV_ASSIGN_OP or_expr { $$ = template("%s /= %s", $1, $3); }
    | assign_expr MOD_ASSIGN_OP or_expr { $$ = template("%s %%= %s", $1, $3); }
;

or_expr:
    and_expr { $$ = $1; }
    | or_expr KEYWORD_OR and_expr { $$ = template("%s || %s", $1, $3); }
;

and_expr:
    not_expr { $$ = $1; }
    | and_expr KEYWORD_AND not_expr { $$ = template("%s && %s", $1, $3); }
;

not_expr:
    comp_expr { $$ = $1; }
    | KEYWORD_NOT not_expr { $$ = template("!%s", $2);  }
;

comp_expr:
    add_expr { $$ = $1; }
    | comp_expr EQUAL_OP add_expr { $$ = template("%s == %s", $1, $3); }
    | comp_expr NEQ_OP add_expr { $$ = template("%s != %s", $1, $3); }
    | comp_expr LESS_OP add_expr { $$ = template("%s < %s", $1, $3); }
    | comp_expr LEQ_OP add_expr { $$ = template("%s <= %s", $1, $3); }
    | comp_expr GREATER_OP add_expr { $$ = template("%s > %s", $1, $3); }
    | comp_expr GREQ_OP add_expr { $$ = template("%s >= %s", $1, $3); }
;

add_expr:
    mult_expr { $$ = $1; }
    | add_expr PLUS_OP mult_expr { $$ = template("%s + %s", $1, $3); }
    | add_expr MINUS_OP mult_expr { $$ = template("%s - %s", $1, $3); }
;

mult_expr:
    unary_expr { $$ = $1; }
    | mult_expr MULT_OP unary_expr { $$ = template("%s * %s", $1, $3); }
    | mult_expr DIV_OP unary_expr { $$ = template("%s / %s", $1, $3); }
    | mult_expr MOD_OP unary_expr { $$ = template("%s %% %s", $1, $3); }
;

unary_expr:
    pow_expr { $$ = $1; }
    | MINUS_OP unary_expr { $$ = template("-%s", $2); }
    | PLUS_OP unary_expr { $$ = $2; }
;

pow_expr:
    primary_expr { $$ = $1; }
    | pow_expr POWER_OP primary_expr { $$ = template("pow(%s, %s)", $1, $3); }
;

primary_expr:
    INTEGER { $$ = $1; }
    | STRING { $$ = $1; }
    | FLOAT { $$ = $1; }
    | IDENTIFIER { $$ = $1; }
    | hash_identifier { $$ = template("self->%s", $1); }
    | KEYWORD_TRUE { $$ = template("1"); }
    | KEYWORD_FALSE { $$ = template("0"); }
    | L_PAREN expression R_PAREN { $$ = template("(%s)", $2); }
    | IDENTIFIER L_BRACKET expression R_BRACKET { $$ = template("%s[%s]", $1, $3); }
    | IDENTIFIER DOT IDENTIFIER { $$ = template("%s.%s", $1, $3); }
    | IDENTIFIER DOT hash_identifier { $$ = template("%s.%s", $1, $3); }
    | IDENTIFIER DOT IDENTIFIER L_PAREN arg_list R_PAREN {
        $$ = template("%s(&%s%s%s)", $3, $1, strlen($5) ? ", " : "", $5);
    }
    //| IDENTIFIER DOT function_call_expr { $$ = template("%s.%s", $1, $3); }
    | hash_identifier DOT function_call_expr { $$ = template("%s.%s", $1, $3); }
    | hash_identifier L_BRACKET expression R_BRACKET { $$ = template("%s[%s]", $1, $3); }
    | hash_identifier L_BRACKET expression R_BRACKET DOT function_call_expr { $$ = template("%s[%s].%s", $1, $3, $6); }
    | hash_identifier L_BRACKET expression R_BRACKET DOT func_hash_identifiers { $$ = template("self->%s[%s].%s", $1, $3, $6); }
 | IDENTIFIER L_BRACKET expression R_BRACKET DOT function_call_expr { $$ = template("%s[%s].%s", $1, $3,$6); }
    | function_call_expr { $$ = $1; }
;

 /*-------------Statements-------------*/
 /* statements_body: one or more commands/expressions ending with ;*/  
statements_body:
  %empty { $$ = template(""); } /* empty statement */
  | statements_body statement  {$$=template("%s\n%s", $1,$2);}
;

statement:
  expr
  | if_statement
  | for_statement
  | while_statement
  | break_statement
  | continue_statement
  | return_statement
  | empty_statement
  | function_call
  | compact_array_integer
  | compact_array_array
;

 /* v = expr; */
 /* v can be IDENTIFIER, array value e.g grade[5]=3; , a field of complex value e.g circle.radius=5; */
value:
  IDENTIFIER { $$ = $1; }
  | HASH IDENTIFIER { $$ = template("self->%s", $2); }
  | array_ref {$$ = $1;}
  | IDENTIFIER DOT IDENTIFIER { $$ = template("%s.%s", $1, $3); }
  | IDENTIFIER DOT hash_identifier { $$ = template("%s.%s", $1, $3); }
  | hash_identifier L_BRACKET expression R_BRACKET { $$ = template("self->%s[%s]", $1, $3); } 
;

 /* expr can also be b+=5 for example and so on*/
expr:
  value ASSIGN_OP expression SEMICOLON { $$ = template("%s = %s;\n", $1, $3); }
  | value PLUS_ASSIGN_OP expression SEMICOLON { $$ = template("%s += %s;\n", $1, $3); }
  | value MINUS_ASSIGN_OP expression SEMICOLON { $$ = template("%s -= %s;\n", $1, $3); }
  | value MULT_ASSIGN_OP expression SEMICOLON { $$ = template("%s *= %s;\n", $1, $3); }
  | value DIV_ASSIGN_OP expression SEMICOLON { $$ = template("%s /= %s;\n", $1, $3); }
  | value MOD_ASSIGN_OP expression SEMICOLON { $$ = template("%s %%= %s;\n", $1, $3); }
/* e.g
   name="John"; */
;


 /* if statement */
 /*
    if(expr):
      statement1
    else:           <-- else is optional
      statement2
    endif;
 */

if_statement:
  KEYWORD_IF L_PAREN expression R_PAREN COLON statements_body opt_else KEYWORD_ENDIF SEMICOLON
  { 
    $$ = template("if(%s) {\n%s}%s\n", $3, $6, $7); 
  }
;

/*optional else*/
opt_else:
  KEYWORD_ELSE COLON statements_body { $$ = template("else {\n%s}", $3); }
  | %empty { $$ = template(""); }
;

 /* for statement */
 /* for int_var in [start:stop:step]:          for (int int_var = start; int_var < stop; int_var += step) {
      statement                          ==>    statement
    endfor;                                         }             
 */

for_statement:
  KEYWORD_FOR IDENTIFIER KEYWORD_IN L_BRACKET expression COLON expression COLON expression R_BRACKET COLON statements_body KEYWORD_ENDFOR SEMICOLON
  { 
    $$ = template("for(int %s=%s; %s<%s; %s=%s+%s) {\n%s};\n", $2, $5, $2, $7, $2, $2, $9, $12); 
  }
  | KEYWORD_FOR IDENTIFIER KEYWORD_IN L_BRACKET expression COLON expression R_BRACKET COLON statements_body KEYWORD_ENDFOR SEMICOLON
  { 
    $$ = template("for(int %s=%s; %s<%s; %s++) {\n%s};\n", $2, $5, $2, $7, $2, $10); 
  }
  /* Add more for_statement rules here if needed */
;

while_statement: 
  KEYWORD_WHILE L_PAREN expression R_PAREN COLON statements_body KEYWORD_ENDWHILE SEMICOLON 
  { 
    $$ = template("while(%s) {\n%s};\n", $3, $6);
  }
;

  /* break statement */
  /* break; */
break_statement: 
  KEYWORD_BREAK SEMICOLON { $$ = template("break;\n"); }
;
  /* continue statement */
  /* continue; */
continue_statement: 
  KEYWORD_CONTINUE SEMICOLON { $$ = template("continue;\n"); } 
;

  /* return statement */
  /* return; or return expr; */
return_statement: 
  KEYWORD_RETURN SEMICOLON { $$ = template("return;\n"); } 
  | KEYWORD_RETURN expression SEMICOLON { $$ = template("return %s;\n", $2); } 
;

  /* function call */
  /* function_name(expr1,expr2,..);*/
  /* predefined functions */
function_call:
  IDENTIFIER L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("%s(%s);\n", $1, $3); }
  | IDENTIFIER DOT IDENTIFIER L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("%s.%s(&%s%s%s);\n", $1, $3, $1, strlen($5) ? "," : "", $5); }
  | hash_identifier DOT IDENTIFIER L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("self->%s.%s(&self->%s%s%s);\n",$1, $3, $1, strlen($5) ? "," : "", $5); }
  | hash_identifier L_BRACKET expression R_BRACKET DOT IDENTIFIER L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("self->%s[%s].%s(&self->%s[%s]);\n", $1, $3, $6, $1, $3, $8 ? "" : ","); }
  | F_READSTR L_PAREN R_PAREN SEMICOLON { $$ = template("readstr();\n"); }
  | F_READINT L_PAREN R_PAREN SEMICOLON { $$ = template("readInteger();\n"); }
  | F_READSC L_PAREN R_PAREN SEMICOLON { $$ = template("readScalar();\n"); }
  | F_WRITESTR L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("writeStr(%s);\n", $3); }
  | F_WRITEINT L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("writeInteger(%s);\n", $3); }
  | F_WRITESC L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("writeScalar(%s);\n", $3); }
  | F_WRITE L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("write(%s);\n", $3); }
;



 /* function calls as expressions */
 /* e.g  a = readInteger(); , j = (N-n) + cube(k);  */

function_call_expr:
  IDENTIFIER L_PAREN arg_list R_PAREN { $$ = template("%s(%s)", $1, $3); }
  | IDENTIFIER DOT hash_identifier L_PAREN arg_list R_PAREN SEMICOLON { $$ = template("%s(%s.%s);\n", $1, $1, $5); }
  | F_READSTR L_PAREN R_PAREN { $$ = template("readstr()"); }
  | F_READINT L_PAREN R_PAREN { $$ = template("readInteger()"); }
  | F_READSC L_PAREN R_PAREN { $$ = template("readScalar()"); }
  | F_WRITESTR L_PAREN arg_list R_PAREN { $$ = template("writeStr(%s)", $3); }
  | F_WRITEINT L_PAREN arg_list R_PAREN { $$ = template("writeInteger(%s)", $3); }
  | F_WRITESC L_PAREN arg_list R_PAREN { $$ = template("writeScalar(%s)", $3); }
  | F_WRITE L_PAREN arg_list R_PAREN { $$ = template("write(%s)", $3); }
;

arg_list:
    %empty { $$ = template(""); }
    | expression { $$ = $1; }
    | arg_list COMMA expression { $$ = template("%s, %s", $1, $3); }
;

  /* empty statement*/
  /* ; */
empty_statement:
  SEMICOLON { $$ = template(";\n"); }

 /* compact array creation over integer */
 /* 
                                                        new_type* new_array = (new_type*)malloc(size * sizeof(new_type));
     new_array := [expr for elm:size] : new_type;  ==>  for(int elm=0; elm<size; elm++) { 
                                                          new_array[elm] = expr;
                                                        }                    
 */

compact_array_integer:
  IDENTIFIER COLON_ASSIGN_OP L_BRACKET expression KEYWORD_FOR IDENTIFIER COLON expression R_BRACKET COLON data_type SEMICOLON
  {
    $$ = template("%s* %s = (%s*)malloc(%s * sizeof(%s));\nfor (int %s = 0; %s < %s; ++%s){\n    %s[%s] = %s;\n}\n",
        $11, $1, $11, $8, $11,     
        $6, $6, $8, $6,            
        $1, $6, $4                
    );
  }
;

/* compact array creation over array */
/* 
     new_type* new_array = (new_type*)malloc(size * sizeof(new_type));
     new_array := [expr for elm: type in array of size] : new_type;  ==>  for (int array_i = 0; array_i < array_size; ++array_i) 
     {new_array[array_i] = expr;}
*/
compact_array_array:
    IDENTIFIER COLON_ASSIGN_OP L_BRACKET expression KEYWORD_FOR IDENTIFIER COLON data_type KEYWORD_IN IDENTIFIER KEYWORD_OF expression R_BRACKET COLON data_type SEMICOLON
{
    // Generate loop variable name (e.g., "a_i" from source array "a")
    char *loop_var = template("%s_i", $10); 

    // Create array access expression (e.g., "a[a_i]")
    char *index_expr = template("%s[%s]", $10, loop_var);

    /*
	Proccess:
		1. Iterate through replaced_exp to find the character that is equal to loop variable. 
			Example: If replaced_expr is "x/2" and $6 is "x", this condition will trigger when i = 0.
		2. When the position of this character is found, replace the character with index_expr and add the remaining part after that.
			Example: If replaced_expr is "x/2", then form 1. i = 0, $6 is "x", and index_expr is "a[a_i]", the new expression becomes: "a[a_i]/2"
		3.  Replace the old expression with the newly constructed one for safety and move the loop index past the replaced portion to avoid reprocessing it.

    	More details in each line.
    */

    // Copy original expression (e.g. "x")
    char *replaced_expr = template("%s", $4);  
    // Loop through original expression
    for (int i = 0; replaced_expr[i]; i++) {
        // Check if current position of original expression matches the loop variable
        if (strncmp(&replaced_expr[i], $6, strlen($6)) == 0) {
            // Replace with array access expression
            char *new_expr = template("%.*s%s%s", 
                                     i, replaced_expr,  // Format the part before the match with the loop variable
                                     index_expr,        // Insert in the formatted part: index_expr (e.g., a[a_i]). In fact we replace x with a[a_i]
                                     &replaced_expr[i + strlen($6)]);  // Finally add the remaining part after.

            free(replaced_expr);
            replaced_expr = new_expr;
            i += strlen(index_expr) - 1;  // Skip ahead
        }
    }

    // Generate C code using the previously created variables
    $$ = template(
        "%s* %s = (%s*)malloc(%s * sizeof(%s));\n"
        "for (int %s = 0; %s < %s; ++%s) {\n"
        "    %s[%s] = %s;\n"
        "}\n",
        $15, $1, $15, $12, $15,  // Type info
        loop_var, loop_var, $12, loop_var,  // Loop parameters
        $1, loop_var, replaced_expr  // Assignment
    );

    // Cleanup of used variables
    free(loop_var);
    free(index_expr);
    free(replaced_expr);
}


/* MAIN */
 main_func:
  KEYWORD_DEF KEYWORD_MAIN L_PAREN R_PAREN COLON function_body KEYWORD_ENDDEF SEMICOLON
  { 
    $$ = template("int main() {\n%s\n}", $6); 
  }
;

 /* Functions */
 /*
    def func_name(func params) --> return_type:           return_type func_name(func params) {
      local variables or consts (optional)                  local variables or consts (optional)   
      statement1  (required)                       ==>      statement1  (required)
      return (optional)                                     return (optional)                                          }
    enddef;                                               }
 */
function_parameters:
  %empty { $$ = template(""); }
  | function_param_list { $$ = $1; }
;

function_param_list:
  function_variables { $$ = template("%s", $1); }
  | function_param_list COMMA function_variables { $$ = template("%s, %s", $1, $3); }
;

/*optionaly could have variables declaration or constants*/
func_var_constants:
  variables { $$ = $1; }
  | constants { $$ = $1; }
;

function_body:
  %empty { $$ = template(""); }
  | function_body func_var_constants { $$ = template("%s\n%s", $1, $2); }
  | function_body statement { $$ = template("%s\n%s", $1, $2); }
;

function_definition:
  KEYWORD_DEF IDENTIFIER L_PAREN function_parameters R_PAREN ARROW data_type COLON function_body return_statement KEYWORD_ENDDEF SEMICOLON
  {
    $$ = template("%s %s(%s) {\n%s\n%s\n}", $7, $2, $4, $9, $10);
  }
  | KEYWORD_DEF IDENTIFIER L_PAREN function_parameters R_PAREN COLON function_body KEYWORD_ENDDEF SEMICOLON
  {
    $$ = template("void %s(%s) {\n%s\n}", $2, $4, $7);
  }
  
;
 

%%

 /* Epilogue */

int main(){
  //puts(c_prologue);
  if(yyparse()==0) 
  	printf("//Correct Syntax !\n");
  else {
    printf("//Wrong Syntax ! \n");
  }
}	
