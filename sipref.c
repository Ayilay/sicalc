#include <math.h>
#include "sipref.h"

struct pref_entry {
  char        pref;
  long double mult;
};

struct pref_entry prefix_funs[] = {
  { 'm', MILI },
  { 'u', MICRO },
  { 'n', NANO  },
  { 'p', PICO  },
  { 'f', FEMTO },
  { 'a', ATTO  },
  { 'z', ZEPTO },
  { 'y', YOCTO },

  { 'k', KILO  },
  { 'M', MEGA  },
  { 'G', GIGA  },
  { 'T', TERA  },
  { 'P', PETA  },
  { 'E', EXA   },
  { 'Z', ZETTA },
  { 'Y', YOTTA },
  { 0, 0 },
};

long double prefmult(char c) {
  struct pref_entry* p =  &prefix_funs[0];
  while (p) {
    if (p->pref == c)
      return p->mult;
    p++;
  }

  return NAN;
}
