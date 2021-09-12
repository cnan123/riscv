//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : print.c
//   Auther       : cnan
//   Created On   : 2021.09.11
//   Description  : 
//
//
//================================================================
#include "simple_system.h"

#include <stdarg.h>
#include <sys/types.h>

extern unsigned int _stack_start;

/************************/
/* Data types and settings */
/************************/
/* Configuration : HAS_FLOAT
        Define to 1 if the platform supports floating point.
*/
#ifndef HAS_FLOAT
#define HAS_FLOAT 1
#endif
/* Configuration : HAS_TIME_H
        Define to 1 if platform has the time.h header file,
        and implementation of functions thereof.
*/
#ifndef HAS_TIME_H
#define HAS_TIME_H 0
#endif
/* Configuration : USE_CLOCK
        Define to 1 if platform has the time.h header file,
        and implementation of functions thereof.
*/
#ifndef USE_CLOCK
#define USE_CLOCK 0
#endif
/* Configuration : HAS_STDIO
        Define to 1 if the platform has stdio.h.
*/
#ifndef HAS_STDIO
#define HAS_STDIO 0
#endif
/* Configuration : HAS_PRINTF
        Define to 1 if the platform has stdio.h and implements the printf
   function.
*/
#ifndef HAS_PRINTF
#define HAS_PRINTF 0
#endif

/* Definitions : COMPILER_VERSION, COMPILER_FLAGS, MEM_LOCATION
        Initialize these strings per platform
*/
#ifndef COMPILER_VERSION
#ifdef __GNUC__
#define COMPILER_VERSION "GCC"
#else
#define COMPILER_VERSION "unknown"
#endif
#endif
#ifndef COMPILER_FLAGS
#define COMPILER_FLAGS "" /* "Please put compiler flags here (e.g. -o3)" */
#endif
#ifndef MEM_LOCATION
#define MEM_LOCATION "STACK"
#endif

/* Data Types :
        To avoid compiler issues, define the data types that need to be used for
   8b, 16b and 32b in <core_portme.h>.

        *Imprtant* :
        ee_ptr_int needs to be the data type used to hold pointers, otherwise
   CoreMark may fail!!!
*/
typedef signed short ee_s16;
typedef unsigned short ee_u16;
typedef signed int ee_s32;
typedef double ee_f32;
typedef unsigned char ee_u8;
typedef unsigned int ee_u32;
typedef ee_u32 ee_ptr_int;
typedef size_t ee_size_t;
#define NULL ((void *)0)
/* align_mem :
        This macro is used to align an offset to point to a 32b value. It is
   used in the Matrix algorithm to initialize the input memory blocks.
*/
#define align_mem(x) (void *)(4 + (((ee_ptr_int)(x)-1) & ~3))

/* Configuration : CORE_TICKS
        Define type of return from the timing functions.
 */
#define CORETIMETYPE ee_u32
typedef ee_u32 CORE_TICKS;

/* Configuration : SEED_METHOD
        Defines method to get seed values that cannot be computed at compile
   time.

        Valid values :
        SEED_ARG - from command line.
        SEED_FUNC - from a system function.
        SEED_VOLATILE - from volatile variables.
*/
#ifndef SEED_METHOD
#define SEED_METHOD SEED_VOLATILE
#endif

/* Configuration : MEM_METHOD
        Defines method to get a block of memry.

        Valid values :
        MEM_MALLOC - for platforms that implement malloc and have malloc.h.
        MEM_STATIC - to use a static memory array.
        MEM_STACK - to allocate the data block on the stack (NYI).
*/
#ifndef MEM_METHOD
#define MEM_METHOD MEM_STACK
#endif

/* Configuration : MULTITHREAD
        Define for parallel execution

        Valid values :
        1 - only one context (default).
        N>1 - will execute N copies in parallel.

        Note :
        If this flag is defined to more then 1, an implementation for launching
   parallel contexts must be defined.

        Two sample implementations are provided. Use <USE_PTHREAD> or <USE_FORK>
   to enable them.

        It is valid to have a different implementation of <core_start_parallel>
   and <core_end_parallel> in <core_portme.c>, to fit a particular architecture.
*/
#ifndef MULTITHREAD
#define MULTITHREAD 1
#define USE_PTHREAD 0
#define USE_FORK 0
#define USE_SOCKET 0
#endif

/* Configuration : MAIN_HAS_NOARGC
        Needed if platform does not support getting arguments to main.

        Valid values :
        0 - argc/argv to main is supported
        1 - argc/argv to main is not supported

        Note :
        This flag only matters if MULTITHREAD has been defined to a value
   greater then 1.
*/
#ifndef MAIN_HAS_NOARGC
#define MAIN_HAS_NOARGC 0
#endif

/* Configuration : MAIN_HAS_NORETURN
        Needed if platform does not support returning a value from main.

        Valid values :
        0 - main returns an int, and return value will be 0.
        1 - platform does not support returning a value from main
*/
#ifndef MAIN_HAS_NORETURN
#define MAIN_HAS_NORETURN 0
#endif

/* Variable : default_num_contexts
        Not used for this simple port, must cintain the value 1.
*/
extern ee_u32 default_num_contexts;

typedef struct CORE_PORTABLE_S { ee_u8 portable_id; } core_portable;

/* target specific init/fini */
void portable_init(core_portable *p, int *argc, char *argv[]);
void portable_fini(core_portable *p);

#if !defined(PROFILE_RUN) && !defined(PERFORMANCE_RUN) && \
    !defined(VALIDATION_RUN)
#if (TOTAL_DATA_SIZE == 1200)
#define PROFILE_RUN 1
#elif (TOTAL_DATA_SIZE == 2000)
#define PERFORMANCE_RUN 1
#else
#define VALIDATION_RUN 1
#endif
#endif

int ee_printf(const char *fmt, ...);


#define ZEROPAD (1 << 0)   /* Pad with zero */
#define SIGN (1 << 1)      /* Unsigned/signed long */
#define PLUS (1 << 2)      /* Show plus */
#define SPACE (1 << 3)     /* Spacer */
#define LEFT (1 << 4)      /* Left justified */
#define HEX_PREP (1 << 5)  /* 0x */
#define UPPERCASE (1 << 6) /* 'ABCDEF' */

#define is_digit(c) ((c) >= '0' && (c) <= '9')

static char *digits = "0123456789abcdefghijklmnopqrstuvwxyz";
static char *upper_digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static ee_size_t strnlen(const char *s, ee_size_t count);

static ee_size_t strnlen(const char *s, ee_size_t count) {
  const char *sc;
  for (sc = s; *sc != '\0' && count--; ++sc)
    ;
  return sc - s;
}

static int skip_atoi(const char **s) {
  int i = 0;
  while (is_digit(**s))
    i = i * 10 + *((*s)++) - '0';
  return i;
}

static char *number(char *str, long num, int base, int size, int precision,
                    int type) {
  char c, sign, tmp[66];
  char *dig = digits;
  int i;

  if (type & UPPERCASE)
    dig = upper_digits;
  if (type & LEFT)
    type &= ~ZEROPAD;
  if (base < 2 || base > 36)
    return 0;

  c = (type & ZEROPAD) ? '0' : ' ';
  sign = 0;
  if (type & SIGN) {
    if (num < 0) {
      sign = '-';
      num = -num;
      size--;
    } else if (type & PLUS) {
      sign = '+';
      size--;
    } else if (type & SPACE) {
      sign = ' ';
      size--;
    }
  }

  if (type & HEX_PREP) {
    if (base == 16)
      size -= 2;
    else if (base == 8)
      size--;
  }

  i = 0;

  if (num == 0)
    tmp[i++] = '0';
  else {
    while (num != 0) {
      tmp[i++] = dig[((unsigned long)num) % (unsigned)base];
      num = ((unsigned long)num) / (unsigned)base;
    }
  }

  if (i > precision)
    precision = i;
  size -= precision;
  if (!(type & (ZEROPAD | LEFT)))
    while (size-- > 0)
      *str++ = ' ';
  if (sign)
    *str++ = sign;

  if (type & HEX_PREP) {
    if (base == 8)
      *str++ = '0';
    else if (base == 16) {
      *str++ = '0';
      *str++ = digits[33];
    }
  }

  if (!(type & LEFT))
    while (size-- > 0)
      *str++ = c;
  while (i < precision--)
    *str++ = '0';
  while (i-- > 0)
    *str++ = tmp[i];
  while (size-- > 0)
    *str++ = ' ';

  return str;
}

static char *eaddr(char *str, unsigned char *addr, int size, int precision,
                   int type) {
  char tmp[24];
  char *dig = digits;
  int i, len;

  if (type & UPPERCASE)
    dig = upper_digits;
  len = 0;
  for (i = 0; i < 6; i++) {
    if (i != 0)
      tmp[len++] = ':';
    tmp[len++] = dig[addr[i] >> 4];
    tmp[len++] = dig[addr[i] & 0x0F];
  }

  if (!(type & LEFT))
    while (len < size--)
      *str++ = ' ';
  for (i = 0; i < len; ++i)
    *str++ = tmp[i];
  while (len < size--)
    *str++ = ' ';

  return str;
}

static char *iaddr(char *str, unsigned char *addr, int size, int precision,
                   int type) {
  char tmp[24];
  int i, n, len;

  len = 0;
  for (i = 0; i < 4; i++) {
    if (i != 0)
      tmp[len++] = '.';
    n = addr[i];

    if (n == 0)
      tmp[len++] = digits[0];
    else {
      if (n >= 100) {
        tmp[len++] = digits[n / 100];
        n = n % 100;
        tmp[len++] = digits[n / 10];
        n = n % 10;
      } else if (n >= 10) {
        tmp[len++] = digits[n / 10];
        n = n % 10;
      }

      tmp[len++] = digits[n];
    }
  }

  if (!(type & LEFT))
    while (len < size--)
      *str++ = ' ';
  for (i = 0; i < len; ++i)
    *str++ = tmp[i];
  while (len < size--)
    *str++ = ' ';

  return str;
}

#if HAS_FLOAT

char *ecvtbuf(double arg, int ndigits, int *decpt, int *sign, char *buf);
char *fcvtbuf(double arg, int ndigits, int *decpt, int *sign, char *buf);
static void ee_bufcpy(char *d, char *s, int count);

void ee_bufcpy(char *pd, char *ps, int count) {
  char *pe = ps + count;
  while (ps != pe)
    *pd++ = *ps++;
}

static void parse_float(double value, char *buffer, char fmt, int precision) {
  int decpt, sign, exp, pos;
  char *digits = NULL;
  char cvtbuf[80];
  int capexp = 0;
  int magnitude;

  if (fmt == 'G' || fmt == 'E') {
    capexp = 1;
    fmt += 'a' - 'A';
  }

  if (fmt == 'g') {
    digits = ecvtbuf(value, precision, &decpt, &sign, cvtbuf);
    magnitude = decpt - 1;
    if (magnitude < -4 || magnitude > precision - 1) {
      fmt = 'e';
      precision -= 1;
    } else {
      fmt = 'f';
      precision -= decpt;
    }
  }

  if (fmt == 'e') {
    digits = ecvtbuf(value, precision + 1, &decpt, &sign, cvtbuf);

    if (sign)
      *buffer++ = '-';
    *buffer++ = *digits;
    if (precision > 0)
      *buffer++ = '.';
    ee_bufcpy(buffer, digits + 1, precision);
    buffer += precision;
    *buffer++ = capexp ? 'E' : 'e';

    if (decpt == 0) {
      if (value == 0.0)
        exp = 0;
      else
        exp = -1;
    } else
      exp = decpt - 1;

    if (exp < 0) {
      *buffer++ = '-';
      exp = -exp;
    } else
      *buffer++ = '+';

    buffer[2] = (exp % 10) + '0';
    exp = exp / 10;
    buffer[1] = (exp % 10) + '0';
    exp = exp / 10;
    buffer[0] = (exp % 10) + '0';
    buffer += 3;
  } else if (fmt == 'f') {
    digits = fcvtbuf(value, precision, &decpt, &sign, cvtbuf);
    if (sign)
      *buffer++ = '-';
    if (*digits) {
      if (decpt <= 0) {
        *buffer++ = '0';
        *buffer++ = '.';
        for (pos = 0; pos < -decpt; pos++)
          *buffer++ = '0';
        while (*digits)
          *buffer++ = *digits++;
      } else {
        pos = 0;
        while (*digits) {
          if (pos++ == decpt)
            *buffer++ = '.';
          *buffer++ = *digits++;
        }
      }
    } else {
      *buffer++ = '0';
      if (precision > 0) {
        *buffer++ = '.';
        for (pos = 0; pos < precision; pos++)
          *buffer++ = '0';
      }
    }
  }

  *buffer = '\0';
}

static void decimal_point(char *buffer) {
  while (*buffer) {
    if (*buffer == '.')
      return;
    if (*buffer == 'e' || *buffer == 'E')
      break;
    buffer++;
  }

  if (*buffer) {
    int n = strnlen(buffer, 256);
    while (n > 0) {
      buffer[n + 1] = buffer[n];
      n--;
    }

    *buffer = '.';
  } else {
    *buffer++ = '.';
    *buffer = '\0';
  }
}

static void cropzeros(char *buffer) {
  char *stop;

  while (*buffer && *buffer != '.')
    buffer++;
  if (*buffer++) {
    while (*buffer && *buffer != 'e' && *buffer != 'E')
      buffer++;
    stop = buffer--;
    while (*buffer == '0')
      buffer--;
    if (*buffer == '.')
      buffer--;
    while (buffer != stop)
      *++buffer = 0;
  }
}

static char *flt(char *str, double num, int size, int precision, char fmt,
                 int flags) {
  char tmp[80];
  char c, sign;
  int n, i;

  // Left align means no zero padding
  if (flags & LEFT)
    flags &= ~ZEROPAD;

  // Determine padding and sign char
  c = (flags & ZEROPAD) ? '0' : ' ';
  sign = 0;
  if (flags & SIGN) {
    if (num < 0.0) {
      sign = '-';
      num = -num;
      size--;
    } else if (flags & PLUS) {
      sign = '+';
      size--;
    } else if (flags & SPACE) {
      sign = ' ';
      size--;
    }
  }

  // Compute the precision value
  if (precision < 0)
    precision = 6;  // Default precision: 6

  // Convert floating point number to text
  parse_float(num, tmp, fmt, precision);

  if ((flags & HEX_PREP) && precision == 0)
    decimal_point(tmp);
  if (fmt == 'g' && !(flags & HEX_PREP))
    cropzeros(tmp);

  n = strnlen(tmp, 256);

  // Output number with alignment and padding
  size -= n;
  if (!(flags & (ZEROPAD | LEFT)))
    while (size-- > 0)
      *str++ = ' ';
  if (sign)
    *str++ = sign;
  if (!(flags & LEFT))
    while (size-- > 0)
      *str++ = c;
  for (i = 0; i < n; i++)
    *str++ = tmp[i];
  while (size-- > 0)
    *str++ = ' ';

  return str;
}

#endif

static int ee_vsprintf(char *buf, const char *fmt, va_list args) {
  int len;
  unsigned long num;
  int i, base;
  char *str;
  char *s;

  int flags;  // Flags to number()

  int field_width;  // Width of output field
  int precision;  // Min. # of digits for integers; max number of chars for from
                  // string
  int qualifier;  // 'h', 'l', or 'L' for integer fields

  for (str = buf; *fmt; fmt++) {
    if (*fmt != '%') {
      *str++ = *fmt;
      continue;
    }

    // Process flags
    flags = 0;
  repeat:
    fmt++;  // This also skips first '%'
    switch (*fmt) {
      case '-':
        flags |= LEFT;
        goto repeat;
      case '+':
        flags |= PLUS;
        goto repeat;
      case ' ':
        flags |= SPACE;
        goto repeat;
      case '#':
        flags |= HEX_PREP;
        goto repeat;
      case '0':
        flags |= ZEROPAD;
        goto repeat;
    }

    // Get field width
    field_width = -1;
    if (is_digit(*fmt))
      field_width = skip_atoi(&fmt);
    else if (*fmt == '*') {
      fmt++;
      field_width = va_arg(args, int);
      if (field_width < 0) {
        field_width = -field_width;
        flags |= LEFT;
      }
    }

    // Get the precision
    precision = -1;
    if (*fmt == '.') {
      ++fmt;
      if (is_digit(*fmt))
        precision = skip_atoi(&fmt);
      else if (*fmt == '*') {
        ++fmt;
        precision = va_arg(args, int);
      }
      if (precision < 0)
        precision = 0;
    }

    // Get the conversion qualifier
    qualifier = -1;
    if (*fmt == 'l' || *fmt == 'L') {
      qualifier = *fmt;
      fmt++;
    }

    // Default base
    base = 10;

    switch (*fmt) {
      case 'c':
        if (!(flags & LEFT))
          while (--field_width > 0)
            *str++ = ' ';
        *str++ = (unsigned char)va_arg(args, int);
        while (--field_width > 0)
          *str++ = ' ';
        continue;

      case 's':
        s = va_arg(args, char *);
        if (!s)
          s = "<NULL>";
        len = strnlen(s, precision);
        if (!(flags & LEFT))
          while (len < field_width--)
            *str++ = ' ';
        for (i = 0; i < len; ++i)
          *str++ = *s++;
        while (len < field_width--)
          *str++ = ' ';
        continue;

      case 'p':
        if (field_width == -1) {
          field_width = 2 * sizeof(void *);
          flags |= ZEROPAD;
        }
        str = number(str, (unsigned long)va_arg(args, void *), 16, field_width,
                     precision, flags);
        continue;

      case 'A':
        flags |= UPPERCASE;

      case 'a':
        if (qualifier == 'l')
          str = eaddr(str, va_arg(args, unsigned char *), field_width,
                      precision, flags);
        else
          str = iaddr(str, va_arg(args, unsigned char *), field_width,
                      precision, flags);
        continue;

      // Integer number formats - set up the flags and "break"
      case 'o':
        base = 8;
        break;

      case 'X':
        flags |= UPPERCASE;

      case 'x':
        base = 16;
        break;

      case 'd':
      case 'i':
        flags |= SIGN;

      case 'u':
        break;

#if HAS_FLOAT

      case 'f':
        str = flt(str, va_arg(args, double), field_width, precision, *fmt,
                  flags | SIGN);
        continue;

#endif

      default:
        if (*fmt != '%')
          *str++ = '%';
        if (*fmt)
          *str++ = *fmt;
        else
          --fmt;
        continue;
    }

    if (qualifier == 'l')
      num = va_arg(args, unsigned long);
    else if (flags & SIGN)
      num = va_arg(args, int);
    else
      num = va_arg(args, unsigned int);

    str = number(str, num, base, field_width, precision, flags);
  }

  *str = '\0';
  return str - buf;
}

int ee_printf(const char *fmt, ...) {
  char buf[256], *p;
  va_list args;
  int n = 0;

  va_start(args, fmt);
  ee_vsprintf(buf, fmt, args);
  va_end(args);
  p = buf;
  while (*p) {
    putchar(*p);
    n++;
    p++;
  }

  return n;
}
