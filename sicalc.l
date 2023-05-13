%option noyywrap

%{
#include <stdio.h>

#include "sipref.h"
#include "calc.h"
#include "sicalc.h"

enum yytokentype parse_varname(YYSTYPE *_yylval, char const* str);
enum yytokentype parse_number(YYSTYPE *_yylval, char const* str);
enum yytokentype parse_prefix(YYSTYPE *_yylval, char const* str);

%}

number    [0-9]*\.?[0-9]+
word      [a-zA-Z_]+
pref      [munpfazykMGTPEZY]

%%

[ \t]     { ;               }
{number}  { return parse_number (&yylval, yytext); }
{pref}    { return parse_prefix(&yylval, yytext); }
{word}    { return parse_varname(&yylval, yytext); }
\n        { return NEWLINE; }
"+"       { return PLUS;    }
"-"       { return MINUS;   }
"*"       { return MULT;    }
"/"       { return DIV;     }
"^"       { return EXPON;   }
"("       { return LPAREN;  }
")"       { return RPAREN;  }
"="       { return ASSIGN;  }
.         { printf("WTF is %s??\n", yytext); return NEWLINE; }

%%

enum yytokentype parse_varname(YYSTYPE *_yylval, char const* str) {
  //printf("Param Obtained: %s\n", str);

  struct symrec *s = getsym (str);
  if (!s)
    s = putsym (str, VAR);
  _yylval->VAR = s;

  return s->type;
}

enum yytokentype parse_number(YYSTYPE *_yylval, char const* str) {
  sscanf (str, "%Lg", &(_yylval->NUM)); 

  //printf("Number Obtained: %s, %Lg\n", str, _yylval->NUM);
  return NUM;
}

enum yytokentype parse_prefix(YYSTYPE *_yylval, char const* str) {
  //sscanf (str, "%Lg", &(_yylval->NUM)); 
  //printf("Prefix: %c\n", str[0]);

  _yylval->PREFIX = str[0];
  return PREFIX;
}
