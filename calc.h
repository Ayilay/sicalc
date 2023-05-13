/* Function type. */
typedef long double (func_t) (long double);

/* Data type for links in the chain of symbols. */
struct symrec
{
  char *name;  /* name of symbol */
  int type;    /* type of symbol: either VAR or FUN */
  union
  {
    long double var;    /* value of a VAR */
    char pref;          /* SI Prefix */
    func_t *fun;        /* value of a FUN */
  } value;
  struct symrec *next;  /* link field */
};

/* The symbol table: a chain of 'struct symrec'. */
extern struct symrec *sym_table;

struct symrec *putsym (char const *name, int sym_type);
struct symrec *getsym (char const *name);
