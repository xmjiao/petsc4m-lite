/*
 * This file contains some macros and function declarations for m2c.
 */

#ifndef __M2C_H__
#define __M2C_H__

#include <stdio.h>
#include <string.h>

#ifndef EXTERN_C
#  ifdef __cplusplus
#    define EXTERN_C extern "C"
#  else
#    define EXTERN_C extern
#  endif
#endif

#ifdef __NVCC__
#define HOST_AND_DEVICE __host__ __device__
#else
#define HOST_AND_DEVICE
#endif

#if (defined(MATLAB_MEX_FILE) || defined(BUILD_MAT)) && !defined(__NVCC__)

EXTERN_C void mexErrMsgIdAndTxt(const char * id, const char * msg, ...);
EXTERN_C void mexWarnMsgIdAndTxt(const char * id, const char * msg, ...);
EXTERN_C int  mexPrintf(const char * msg, ...);

#define M2C_error   mexErrMsgIdAndTxt
#define M2C_warn    mexWarnMsgIdAndTxt

EXTERN_C void M2C_error(const char * id, const char * msg, ...);
EXTERN_C void M2C_warn(const char * id, const char * msg, ...);

#endif /* MATLAB_MEX_FILE || BUILD_MAT */

#if defined(MATLAB_MEX_FILE) && !defined(__NVCC__)
#define M2C_printf  mexPrintf
#define emlrtIsMATLABThread(s)  1
#else
#define M2C_printf  printf
#define emlrtIsMATLABThread(s)  0
#endif /* MATLAB_MEX_FILE */

/* Define emxArray__common and other standard emxInit and emxFree
 * functions for basic data types. */
#ifndef struct_emxArray__common
#define struct_emxArray__common

struct emxArray__common
{
    void *data;
    int *size;
    int allocatedSize;
    int numDimensions;
    unsigned char canFreeData;
};

#endif

#ifndef typedef_emxArray__common
#define typedef_emxArray__common

typedef struct emxArray__common emxArray__common;

#endif

#ifndef INLINE_ENSURE_CAPACITY
#if defined(_STDC_C99) || defined(__cplusplus)
#define INLINE_ENSURE_CAPACITY  1
#else
#define INLINE_ENSURE_CAPACITY  0
#endif /* _STDC_C99 */
#endif /* INLINE_ENSURE_CAPACITY */

HOST_AND_DEVICE extern
void m2cExpandCapacity(emxArray__common *emxArray, int oldNumel,
        int newNumel, unsigned int elementSize);

/* emxEnsureCapacity is called very frequently, so better to inline it */
#if INLINE_ENSURE_CAPACITY
HOST_AND_DEVICE inline
void emxEnsureCapacity(emxArray__common *emxArray, int oldNumel,
        unsigned int elementSize) {
    int i;
    int newNumel = emxArray->size[0];
    for (i = emxArray->numDimensions-1; i >= 1 ; i--) {
        newNumel *= emxArray->size[i];
    }
    if (newNumel > emxArray->allocatedSize)
        m2cExpandCapacity(emxArray, oldNumel, newNumel, elementSize);
}
#else /* INLINE_ENSURE_CAPACITY */
HOST_AND_DEVICE extern
void emxEnsureCapacity(emxArray__common *emxArray, int oldNumel,
        unsigned int elementSize);
#endif /* INLINE_ENSURE_CAPACITY */

#define declare_emxEnsureCapacity(emxtype) \
HOST_AND_DEVICE extern \
void emxEnsureCapacity_##emxtype(emxArray_##emxtype *pEmxArray, int numDimensions)

#define declare_emxInit(emxtype) \
HOST_AND_DEVICE extern \
void emxInit_##emxtype(emxArray_##emxtype **pEmxArray, int numDimensions)

#define declare_emxFree(emxtype) \
HOST_AND_DEVICE extern \
void emxFree_##emxtype(emxArray_##emxtype **pEmxArray)

#ifdef struct_emxArray_boolean_T
declare_emxInit(boolean_T);
declare_emxEnsureCapacity(boolean_T);
declare_emxFree(boolean_T);
#endif

#ifdef struct_emxArray_char_T
declare_emxInit(char_T);
declare_emxEnsureCapacity(char_T);
declare_emxFree(char_T);
#endif

#ifdef struct_emxArray_int8_T
declare_emxInit(int8_T);
declare_emxEnsureCapacity(int8_T);
declare_emxFree(int8_T);
#endif

#ifdef struct_emxArray_int16_T
declare_emxInit(int16_T);
declare_emxEnsureCapacity(int16_T);
declare_emxFree(int16_T);
#endif

#ifdef struct_emxArray_int32_T
declare_emxInit(int32_T);
declare_emxEnsureCapacity(int32_T);
declare_emxFree(int32_T);
#endif

#ifdef struct_emxArray_int64_T
declare_emxInit(int64_T);
declare_emxEnsureCapacity(int64_T);
declare_emxFree(int64_T);
#endif

#ifdef struct_emxArray_uint8_T
declare_emxInit(uint8_T);
declare_emxEnsureCapacity(uint8_T);
declare_emxFree(uint8_T);
#endif

#ifdef struct_emxArray_uint16_T
declare_emxInit(uint16_T);
declare_emxEnsureCapacity(uint16_T);
declare_emxFree(uint16_T);
#endif

#ifdef struct_emxArray_uint32_T
declare_emxInit(uint32_T);
declare_emxEnsureCapacity(uint32_T);
declare_emxFree(uint32_T);
#endif

#ifdef struct_emxArray_uint64_T
declare_emxInit(uint64_T);
declare_emxEnsureCapacity(uint64_T);
declare_emxFree(uint64_T);
#endif

#ifdef struct_emxArray_real_T
declare_emxInit(real_T);
declare_emxEnsureCapacity(real_T);
declare_emxFree(real_T);
#endif

#ifdef struct_emxArray_real32_T
declare_emxInit(real32_T);
declare_emxEnsureCapacity(real32_T);
declare_emxFree(real32_T);
#endif

#ifdef struct_emxArray_real64_T
declare_emxInit(real64_T);
declare_emxEnsureCapacity(real64_T);
declare_emxFree(real64_T);
#endif

extern double M2C_wtime();

#endif
