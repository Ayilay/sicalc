%{
  #include <stdio.h>  /* For printf, etc. */
  #include <math.h>   /* For pow, used in the grammar. */
  #include "calc.h"   /* Contains definition of 'symrec'. */
  #include "sicalc.h"
  #include "sipref.h"

  void yyerror (char const *);
  void print_expr(long double d);
  
  extern int yylex (void);
  extern FILE* yyin;
%}

%define api.value.type union /* Generate YYSTYPE from these types: */
%token NEWLINE
%token LPAREN RPAREN

%token <long double>  NUM        /* Double precision number. */
%token <struct symrec*> VAR FUN  /* Symbol table pointer: variable/function. */
%token <char> PREFIX             /* SI Prefix */
%nterm <long double>  expr

%precedence ASSIGN
%left MINUS PLUS
%left MULT DIV
%precedence NEG /* negation--unary minus */
%right EXPON    /* exponentiation */

/* Generate the parser description file. */
%verbose

/* Formatting semantic values. */
%printer { fprintf (yyo, "%s", $$->name); } VAR;
%printer { fprintf (yyo, "%s()", $$->name); } FUN;
%printer { fprintf (yyo, "%g", (double) $$); } <long double>;

%%
input:
  %empty
| input line
;

line:
  NEWLINE
| expr NEWLINE    { print_expr($1);                  }
| error NEWLINE   { yyerrok;                         }
;

expr:
  NUM
| VAR                     { $$ = $1->value.var;              }
| expr PREFIX             { $$ = $1 * prefmult($2);}
| VAR ASSIGN expr         { $$ = $3; $1->value.var = $3;     }
| FUN LPAREN expr RPAREN  { $$ = $1->value.fun ($3);         }
| expr PLUS expr          { $$ = $1 + $3;                    }
| expr MINUS expr         { $$ = $1 - $3;                    }
| expr MULT expr          { $$ = $1 * $3;                    }
| expr DIV expr           { $$ = $1 / $3;                    }
| MINUS expr  %prec NEG   { $$ = -$2;                        }
| expr EXPON expr         { $$ = pow ($1, $3);               }
| LPAREN expr RPAREN      { $$ = $2;                         }
;
/* End of grammar. */
%%

struct init
{
  char const *name;
  func_t *fun;
};

struct init const arith_funs[] =
{
  { "atan", atanl },
  { "cos",  cosl  },
  { "exp",  expl  },
  { "ln",   logl  },
  { "sin",  sinl  },
  { "sqrt", sqrtl },
  { 0, 0 },
};


/* The symbol table: a chain of 'struct symrec'. */
struct symrec *sym_table;

/* Put arithmetic functions in table. */
static void
init_table (void)
{
  for (int i = 0; arith_funs[i].name; i++)
    {
      struct symrec *ptr = putsym (arith_funs[i].name, FUN);
      ptr->value.fun = arith_funs[i].fun;
    }
}

/* The mfcalc code assumes that malloc and realloc
   always succeed, and that integer calculations
   never overflow.  Production-quality code should
   not make these assumptions.  */
#include <stdlib.h> /* malloc, realloc. */
#include <string.h> /* strlen. */

struct symrec *
putsym (char const *name, int sym_type)
{
  struct symrec *res = (struct symrec *) malloc (sizeof (struct symrec));
  res->name = strdup (name);
  res->type = sym_type;
  res->value.var = 0; /* Set value to 0 even if fun. */
  res->next = sym_table;
  sym_table = res;
  return res;
}

struct symrec *
getsym (char const *name)
{
  for (struct symrec *p = sym_table; p; p = p->next)
    if (strcmp (p->name, name) == 0)
      return p;
  return NULL;
}

void print_expr(long double d) {
 printf ("%.10Lg\n", d); 
}

#include <ctype.h>
#include <stddef.h>

/* Called by yyparse on error. */
void yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

int main (int argc, char const* argv[])
{
  /* Enable parse traces on option -p. */
  if (argc == 2 && strcmp(argv[1], "-p") == 0)
    yydebug = 1;
  init_table ();
  return yyparse ();
}
