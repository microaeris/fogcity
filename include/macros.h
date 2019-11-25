#ifndef MACROS_H
#define MACROS_H

// Constants

#define TRUE  1
#define FALSE 0

// Types

typedef unsigned char       bool;
typedef signed char         int8_t;
typedef unsigned char       uint8_t;
typedef signed short int    int16_t;
typedef unsigned short int  uint16_t;
typedef signed int          int32_t;
typedef unsigned int        uint32_t;
typedef int8_t              int8;
typedef uint8_t             uint8;
typedef int16_t             int16;
typedef uint16_t            uint16;
typedef int32_t             int32;
typedef uint32_t            uint32;

// Includes

#include <assert.h>

// Shared Function-like Macros

#define ASSERT(expr) { debug_assert(expr); }

#endif /* MACROS_H */
