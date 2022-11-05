/*
 * rtwtypes.h
 *
 */

#if (defined(MATLAB_MEX_FILE) || defined(BUILD_MAT)) && !defined(OCTAVE_MEX_FILE)
#include "tmwtypes.h" /* Use MATLAB's TMWTYPES */
#else
#include <stdint.h>
#endif

#ifndef __RTWTYPES_H__
#define __RTWTYPES_H__
#ifndef TRUE
# define TRUE (1U)
#endif
#ifndef FALSE
# define FALSE (0U)
#endif
#ifndef __TMWTYPES__
#define __TMWTYPES__

#include <limits.h>

/*=======================================================================*
 * Target hardware information
 *   Device type: Generic->MATLAB Host Computer
 *   Number of bits:     char:   8    short:   16    int:  32
 *                       long:  64      native word size:  64
 *   Byte ordering: LittleEndian
 *   Signed integer division rounds to: Zero
 *   Shift right on a signed integer as arithmetic shift: on
 *=======================================================================*/

/*=======================================================================*
 * Fixed width word size data types:                                     *
 *   int8_T, int16_T, int32_T     - signed 8, 16, or 32 bit integers     *
 *   uint8_T, uint16_T, uint32_T  - unsigned 8, 16, or 32 bit integers   *
 *   real32_T, real64_T           - 32 and 64 bit floating point numbers *
 *=======================================================================*/

typedef signed char int8_T;
typedef unsigned char uint8_T;
typedef short int16_T;
typedef unsigned short uint16_T;
typedef int int32_T;
typedef unsigned int uint32_T;

typedef float real32_T;
typedef double real64_T;

/*=======================================================================*
 * Fixed width word size data types:                                     *
 *   int64_T                      - signed 64 bit integers               *
 *   uint64_T                     - unsigned 64 bit integers             *
 *=======================================================================*/

#ifndef INT64_T
# if defined(__APPLE__)
#  define INT64_T long long
#  define FMT64 "ll"
#  if defined(__LP64__) && !defined(INT_TYPE_64_IS_LONG)
#    define INT_TYPE_64_IS_LONG
#  endif
# elif (defined(__x86_64__) || defined(__LP64__))&& !defined(__MINGW64__)
#  define INT64_T long
#  define FMT64 "l"
#  if !defined(INT_TYPE_64_IS_LONG)
#    define INT_TYPE_64_IS_LONG
#  endif
# elif defined(_MSC_VER) || (defined(__BORLANDC__) && __BORLANDC__ >= 0x530) \
                         || (defined(__WATCOMC__)  && __WATCOMC__  >= 1100)
#  define INT64_T __int64
#  define FMT64 "I64"
# elif defined(__GNUC__) || defined(TMW_ENABLE_INT64) \
                         || defined(__LCC64__)
#  define INT64_T long long
#  define FMT64 "ll"
# endif
#endif


#if defined(INT64_T)
# if defined(__GNUC__) && \
    ((__GNUC__ > 2) || ((__GNUC__ == 2) && (__GNUC_MINOR__ >=9)))
  __extension__
# endif
 typedef INT64_T int64_T;
#endif

#ifndef UINT64_T
# if defined(__APPLE__)
#  define UINT64_T unsigned long long
#  define FMT64 "ll"
#  if defined(__LP64__) && !defined(INT_TYPE_64_IS_LONG)
#    define INT_TYPE_64_IS_LONG
#  endif
# elif (defined(__x86_64__) || defined(__LP64__))&& !defined(__MINGW64__)
#  define UINT64_T unsigned long
#  define FMT64 "l"
#  if !defined(INT_TYPE_64_IS_LONG)
#    define INT_TYPE_64_IS_LONG
#  endif
# elif defined(_MSC_VER) || (defined(__BORLANDC__) && __BORLANDC__ >= 0x530) \
                         || (defined(__WATCOMC__)  && __WATCOMC__  >= 1100)
#  define UINT64_T unsigned __int64
#  define FMT64 "I64"
# elif defined(__GNUC__) || defined(TMW_ENABLE_INT64) \
                         || defined(__LCC64__)
#  define UINT64_T unsigned long long
#  define FMT64 "ll"
# endif
#endif


#if defined(_WIN64) || (defined(__APPLE__) && defined(__LP64__)) \
                    || defined(__x86_64__) \
                    || defined(__LP64__)
#  define INT_TYPE_64_IS_SUPPORTED
#endif

#if defined(UINT64_T)
# if defined(__GNUC__) && \
    ((__GNUC__ > 2) || ((__GNUC__ == 2) && (__GNUC_MINOR__ >=9)))
  __extension__
# endif
 typedef UINT64_T uint64_T;
#endif

/*===========================================================================*
 * Generic type definitions: real_T, time_T, boolean_T, int_T, uint_T,       *
 *                           ulong_T, char_T and byte_T.                     *
 *===========================================================================*/

typedef double real_T;
typedef double time_T;
typedef unsigned char boolean_T;
typedef int int_T;
typedef unsigned uint_T;
typedef unsigned long ulong_T;
typedef char char_T;
typedef char_T byte_T;

/*===========================================================================*
 * Complex number type definitions                                           *
 *===========================================================================*/
#define CREAL_T
   typedef struct {
     real32_T re;
     real32_T im;
   } creal32_T;

   typedef struct {
     real64_T re;
     real64_T im;
   } creal64_T;

   typedef struct {
     real_T re;
     real_T im;
   } creal_T;

   typedef struct {
     int8_T re;
     int8_T im;
   } cint8_T;

   typedef struct {
     uint8_T re;
     uint8_T im;
   } cuint8_T;

   typedef struct {
     int16_T re;
     int16_T im;
   } cint16_T;

   typedef struct {
     uint16_T re;
     uint16_T im;
   } cuint16_T;

   typedef struct {
     int32_T re;
     int32_T im;
   } cint32_T;

   typedef struct {
     uint32_T re;
     uint32_T im;
   } cuint32_T;


/*=======================================================================*
 * Min and Max:                                                          *
 *   int8_T, int16_T, int32_T     - signed 8, 16, or 32 bit integers     *
 *   uint8_T, uint16_T, uint32_T  - unsigned 8, 16, or 32 bit integers   *
 *=======================================================================*/

#define MAX_int8_T  	((int8_T)(127))
#define MIN_int8_T  	((int8_T)(-128))
#define MAX_uint8_T 	((uint8_T)(255))
#define MIN_uint8_T 	((uint8_T)(0))
#define MAX_int16_T 	((int16_T)(32767))
#define MIN_int16_T 	((int16_T)(-32768))
#define MAX_uint16_T	((uint16_T)(65535))
#define MIN_uint16_T	((uint16_T)(0))
#define MAX_int32_T 	((int32_T)(2147483647))
#define MIN_int32_T 	((int32_T)(-2147483647-1))
#define MAX_uint32_T	((uint32_T)(0xFFFFFFFFU))
#define MIN_uint32_T	((uint32_T)(0))
#define MAX_int64_T	((int64_T)(9223372036854775807L))
#define MIN_int64_T	((int64_T)(-9223372036854775807L-1L))
#define MAX_uint64_T	((uint64_T)(0xFFFFFFFFFFFFFFFFUL))
#define MIN_uint64_T	((uint64_T)(0UL))

/* Logical type definitions */
#if !defined(__cplusplus) && !defined(__bool_true_false_are_defined)

#ifndef _bool_T
#define _bool_T

#ifndef false
#define false (0)
#endif
#ifndef true
#define true (1)
#endif

#endif /* _bool_T */

#endif /* !__cplusplus */

/*
 * MATLAB for code generation assumes the code is compiled on a target using a 2's compliment representation
 * for signed integer values.
 */
#if ((SCHAR_MIN + 1) != -SCHAR_MAX)
#error "This code must be compiled using a 2's complement representation for signed integer values"
#endif

/*
 * Maximum length of a MATLAB identifier (function/variable)
 * including the null-termination character. Referenced by
 * rt_logging.c and rt_matrx.c.
 */
#define TMW_NAME_LENGTH_MAX	64

#endif /* __TMWTYPES__ */

#endif
