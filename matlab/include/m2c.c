/*
 * This file contains public functions for m2c.
 */

/* Always define an non-inlined version of emxEnsureCapacity to
 * avoid linking errors */
#if INLINE_ENSURE_CAPACITY
#undef INLINE_ENSURE_CAPACITY
#endif
#define INLINE_ENSURE_CAPACITY  0

#include "m2c.h"

#if (defined(MATLAB_MEX_FILE) || defined(BUILD_MAT)) && !defined(__NVCC__)

/* Define macros to support building function into MATLAB executable. */
#ifdef malloc
# error Function malloc was previously defined as a macro. This can cause MEX functions to fail.
#endif

EXTERN_C void *mxMalloc(size_t n);
EXTERN_C void *mxCalloc(size_t n, size_t size);
EXTERN_C void *mxRealloc(void *ptr, size_t size);
EXTERN_C void mxFree(void *ptr);

#define malloc  mxMalloc
#define calloc  mxCalloc
#define realloc mxRealloc
#define free    mxFree

#endif /* MATLAB_MEX_FILE || BUILD_MAT */

HOST_AND_DEVICE
void m2cExpandCapacity(emxArray__common *emxArray, int oldNumel,
                       int newNumel, unsigned int elementSize)
{
    int n;
    void *newData;

    if (emxArray->allocatedSize==0)
        n = newNumel;
    else {
        n = emxArray->allocatedSize;
        if (n < 16) {
            n = 16;
        }
        while (n < newNumel) {
            /* Double size each time to minimize number of reallocation. */
            n <<= 1;
        }
    }

    newData = calloc((unsigned int)n, (unsigned int)elementSize);
    if (emxArray->data != NULL) {
        memcpy(newData, emxArray->data, (uint32_T)(elementSize * oldNumel));
        if (emxArray->canFreeData) {
            free(emxArray->data);
        }
    }

    emxArray->data = newData;
    emxArray->allocatedSize = n;
    emxArray->canFreeData = 1;
}

HOST_AND_DEVICE
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

#define define_emxEnsureCapacity(emxtype) \
HOST_AND_DEVICE \
void emxEnsureCapacity_##emxtype(emxArray_##emxtype *pEmxArray, int oldNumel) \
{ \
    emxEnsureCapacity((emxArray__common *)pEmxArray, oldNumel, sizeof(emxtype)); \
}

#define define_emxInit(emxtype) \
HOST_AND_DEVICE \
void emxInit_##emxtype(emxArray_##emxtype **pEmxArray, int numDimensions) \
{ \
    emxArray_##emxtype *emxArray; \
    int i; \
    *pEmxArray = (emxArray_##emxtype *)malloc(sizeof(emxArray_##emxtype)); \
    emxArray = *pEmxArray; \
    emxArray->data = NULL; \
    emxArray->numDimensions = numDimensions; \
    emxArray->size = (int *)malloc((unsigned int)(sizeof(int) * numDimensions)); \
    emxArray->allocatedSize = 0; \
    emxArray->canFreeData = 1; \
    for (i = 0; i < numDimensions; i++) { \
        emxArray->size[i] = 0; \
    } \
}

/* Define emxFree for standard data types */
#define define_emxFree(emxtype) \
HOST_AND_DEVICE \
void emxFree_##emxtype(emxArray_##emxtype **pEmxArray) \
{ \
    if (*pEmxArray != (emxArray_##emxtype *)NULL) { \
        if ((*pEmxArray)->canFreeData) { \
            free((void *)(*pEmxArray)->data); \
        } \
        \
        free((void *)(*pEmxArray)->size); \
        free((void *)*pEmxArray); \
        *pEmxArray = (emxArray_##emxtype *)NULL; \
    } \
}


#define define_emxCreate(emxInit, emxtype) \
HOST_AND_DEVICE \
emxArray_##emxtype *emxCreate_##emxtype(int rows, int cols) \
{ \
    emxArray_##emxtype *emx; \
    int numEl; \
    emxInit(&emx, 2); \
    emx->size[0] = rows; \
    emx->size[1] = cols; \
    numEl = rows*cols; \
    *(void **)&emx->data = calloc((uint32_T)numEl, sizeof(*emx->data)); \
    emx->numDimensions = 2; \
    emx->allocatedSize = numEl; \
    return emx; \
}

#define define_emxFreeStruct(emxFree, emxtype) \
HOST_AND_DEVICE \
void emxFree(emxArray_##emxtype **pEmxArray) \
{ \
    int numEl; \
    int i; \
    if (*pEmxArray != (emxArray_##emxtype*)NULL) { \
        numEl = 1; \
        for (i = 0; i < (*pEmxArray)->numDimensions; i++) { \
            numEl *= (*pEmxArray)->size[i]; \
        } \
        \
        for (i = 0; i < numEl; i++) { \
            emxFreeStruct_##emxtype(&(*pEmxArray)->data[i]); \
        } \
        \
        if ((*pEmxArray)->canFreeData) { \
            free((void *)(*pEmxArray)->data); \
        } \
        \
        free((void *)(*pEmxArray)->size); \
        free((void *)*pEmxArray); \
        *pEmxArray = (emxArray_##emxtype *)NULL; \
    } \
}

#define define_emxCreateND(emxInit, emxtype) \
HOST_AND_DEVICE \
emxArray_##emxtype *emxCreateND_##emxtype(int numDimensions, int *size)  \
{ \
    emxArray_##emxtype *emx; \
    int numEl; \
    int i; \
    emxInit(&emx, numDimensions); \
    numEl = 1; \
    for (i = 0; i < numDimensions; i++) { \
        numEl *= size[i]; \
        emx->size[i] = size[i]; \
    } \
    \
    *(void **)&emx->data = calloc((uint32_T)numEl, sizeof(*emx->data)); \
    emx->numDimensions = numDimensions; \
    emx->allocatedSize = numEl; \
    return emx; \
}


#define define_emxCreateWrapper(emxInit, emxtype, type) \
HOST_AND_DEVICE \
emxArray_##emxtype *emxCreateWrapper_##emxtype(type *data, int rows, int cols) \
{ \
    emxArray_##emxtype *emx; \
    emxInit(&emx, 2); \
    emx->size[0] = rows; \
    emx->size[1] = cols; \
    \
    emx->data = data; \
    emx->numDimensions = 2; \
    emx->allocatedSize = rows*cols; \
    emx->canFreeData = FALSE; \
    return emx; \
}

#define define_emxCreateWrapperND(emxInit, emxtype, type) \
HOST_AND_DEVICE \
emxArray_##emxtype *emxCreateWrapperND_##emxtype(type *data, int numDimensions, \
        int *size) \
{ \
    emxArray_##emxtype *emx; \
    int numEl; \
    int i; \
    emxInit(&emx, numDimensions); \
    numEl = 1; \
    for (i = 0; i < numDimensions; i++) { \
        numEl *= size[i]; \
        emx->size[i] = size[i]; \
    } \
    \
    emx->data = data; \
    emx->numDimensions = numDimensions; \
    emx->allocatedSize = numEl; \
    emx->canFreeData = FALSE; \
    return emx; \
}

#define define_emxDestroyArray(emxFree, type) \
HOST_AND_DEVICE \
void emxDestroyArray_##type(emxArray_##type *emxArray) \
{ \
    emxFree(&emxArray); \
}

#ifdef struct_emxArray_boolean_T
        define_emxInit(boolean_T)
        define_emxEnsureCapacity(boolean_T)
        define_emxFree(boolean_T)

        define_emxCreate(emxInit_boolean_T, boolean_T)
        define_emxCreateND(emxInit_boolean_T, boolean_T)
        define_emxCreateWrapper(emxInit_boolean_T, boolean_T, unsigned char)
        define_emxCreateWrapperND(emxInit_boolean_T, boolean_T, unsigned char)
        define_emxDestroyArray(emxFree_boolean_T, boolean_T)
#endif


#ifdef struct_emxArray_char_T
        define_emxInit(char_T)
        define_emxEnsureCapacity(char_T)
        define_emxFree(char_T)

        define_emxCreate(emxInit_char_T, char_T)
        define_emxCreateND(emxInit_char_T, char_T)
        define_emxCreateWrapper(emxInit_char_T, char_T, char)
        define_emxCreateWrapperND(emxInit_char_T, char_T, char)
        define_emxDestroyArray(emxFree_char_T, char_T)
#endif

#ifdef struct_emxArray_int8_T
        define_emxInit(int8_T)
        define_emxEnsureCapacity(int8_T)
        define_emxFree(int8_T)

        define_emxCreate(emxInit_int8_T, int8_T)
        define_emxCreateND(emxInit_int8_T, int8_T)
        define_emxCreateWrapper(emxInit_int8_T, int8_T, signed char)
        define_emxCreateWrapperND(emxInit_int8_T, int8_T, signed char)
        define_emxDestroyArray(emxFree_int8_T, int8_T)
#endif

#ifdef struct_emxArray_int16_T
        define_emxInit(int16_T)
        define_emxEnsureCapacity(int16_T)
        define_emxFree(int16_T)

        define_emxCreate(emxInit_int16_T, int16_T)
        define_emxCreateND(emxInit_int16_T, int16_T)
        define_emxCreateWrapper(emxInit_int16_T, int16_T, short)
        define_emxCreateWrapperND(emxInit_int16_T, int16_T, short)
        define_emxDestroyArray(emxFree_int16_T, int16_T)
#endif

#ifdef struct_emxArray_int32_T
        define_emxInit(int32_T)
        define_emxEnsureCapacity(int32_T)
        define_emxFree(int32_T)

        define_emxCreate(emxInit_int32_T, int32_T)
        define_emxCreateND(emxInit_int32_T, int32_T)
        define_emxCreateWrapper(emxInit_int32_T, int32_T, int)
        define_emxCreateWrapperND(emxInit_int32_T, int32_T, int)
        define_emxDestroyArray(emxFree_int32_T, int32_T)
#endif

#ifdef struct_emxArray_int64_T
        define_emxInit(int64_T)
        define_emxEnsureCapacity(int64_T)
        define_emxFree(int64_T)

        define_emxCreate(emxInit_int64_T, int64_T)
        define_emxCreateND(emxInit_int64_T, int64_T)
#ifdef _MSC_VER
        define_emxCreateWrapper(emxInit_int64_T, int64_T, __int64)
        define_emxCreateWrapperND(emxInit_int64_T, int64_T, __int64)
#else
        define_emxCreateWrapper(emxInit_int64_T, int64_T, long)
        define_emxCreateWrapperND(emxInit_int64_T, int64_T, long)
#endif
        define_emxDestroyArray(emxFree_int64_T, int64_T)
#endif

#ifdef struct_emxArray_uint8_T
        define_emxInit(uint8_T)
        define_emxEnsureCapacity(uint8_T)
        define_emxFree(uint8_T)

        define_emxCreate(emxInit_uint8_T, uint8_T)
        define_emxCreateND(emxInit_uint8_T, uint8_T)
        define_emxCreateWrapper(emxInit_uint8_T, uint8_T, unsigned char)
        define_emxCreateWrapperND(emxInit_uint8_T, uint8_T, unsigned char)
        define_emxDestroyArray(emxFree_uint8_T, uint8_T)
#endif

#ifdef struct_emxArray_uint16_T
        define_emxInit(uint16_T)
        define_emxEnsureCapacity(uint16_T)
        define_emxFree(uint16_T)

        define_emxCreate(emxInit_uint16_T, uint16_T)
        define_emxCreateND(emxInit_uint16_T, uint16_T)
        define_emxCreateWrapper(emxInit_uint16_T, uint16_T, unsigned short)
        define_emxCreateWrapperND(emxInit_uint16_T, uint16_T, unsigned short)
        define_emxDestroyArray(emxFree_uint16_T, uint16_T)
#endif

#ifdef struct_emxArray_uint32_T
        define_emxInit(uint32_T)
        define_emxEnsureCapacity(uint32_T)
        define_emxFree(uint32_T)

        define_emxCreate(emxInit_uint32_T, uint32_T)
        define_emxCreateND(emxInit_uint32_T, uint32_T)
        define_emxCreateWrapper(emxInit_uint32_T, uint32_T, unsigned int)
        define_emxCreateWrapperND(emxInit_uint32_T, uint32_T, unsigned int)
        define_emxDestroyArray(emxFree_uint32_T, uint32_T)
#endif

#ifdef struct_emxArray_uint64_T
        define_emxInit(uint64_T)
        define_emxEnsureCapacity(uint64_T)
        define_emxFree(uint64_T)

        define_emxCreate(emxInit_uint64_T, uint64_T)
        define_emxCreateND(emxInit_uint64_T, uint64_T)
#ifdef _MSC_VER
        define_emxCreateWrapper(emxInit_uint64_T, uint64_T, unsigned __int64)
        define_emxCreateWrapperND(emxInit_uint64_T, uint64_T, unsigned __int64)
#else
        define_emxCreateWrapper(emxInit_uint64_T, uint64_T, unsigned long)
        define_emxCreateWrapperND(emxInit_uint64_T, uint64_T, unsigned long)
#endif
        define_emxDestroyArray(emxFree_uint64_T, uint64_T)
#endif

#ifdef struct_emxArray_real_T
        define_emxInit(real_T)
        define_emxEnsureCapacity(real_T)
        define_emxFree(real_T)

        define_emxCreate(emxInit_real_T, real_T)
        define_emxCreateND(emxInit_real_T, real_T)
        define_emxCreateWrapper(emxInit_real_T, real_T, double)
        define_emxCreateWrapperND(emxInit_real_T, real_T, double)
        define_emxDestroyArray(emxFree_real_T, real_T)
#endif

#ifdef struct_emxArray_real32_T
        define_emxInit(real32_T)
        define_emxEnsureCapacity(real32_T)
        define_emxFree(real32_T)

        define_emxCreate(emxInit_real32_T, real32_T)
        define_emxCreateND(emxInit_real32_T, real32_T)
        define_emxCreateWrapper(emxInit_real32_T, real32_T, float)
        define_emxCreateWrapperND(emxInit_real32_T, real32_T, float)
        define_emxDestroyArray(emxFree_real32_T, real32_T)
#endif

#ifdef struct_emxArray_real64_T
        define_emxInit(real64_T)
        define_emxEnsureCapacity(real64_T)
        define_emxFree(real64_T)

        define_emxCreate(emxInit_real64_T, real64_T)
        define_emxCreateND(emxInit_real64_T, real64_T)
        define_emxCreateWrapper(emxInit_real64_T, real64_T, double)
        define_emxCreateWrapperND(emxInit_real64_T, real64_T, double)
        define_emxDestroyArray(emxFree_real64_T, real64_T)
#endif

#include <time.h>

#if defined(__GNUC__)
#include <sys/time.h>
#else

#ifdef _MSC_VER
        /* Provides an implementation of gettimeofday for Windows
         */
#include <windows.h>
#elif !defined(__LCC__)
#include <math.h>
#endif

#if defined(_MSC_VER) || defined(_MSC_EXTENSIONS)
#define DELTA_EPOCH_IN_MICROSECS  11644473600000000Ui64
#else
#define DELTA_EPOCH_IN_MICROSECS  11644473600000000ULL
#endif

struct timezone
{
    int  tz_minuteswest; /* minutes W of Greenwich */
    int  tz_dsttime;     /* type of dst correction */
};

// Definition of a gettimeofday function

int gettimeofday(struct timeval *tv, struct timezone *tz)
{
#ifdef _MSC_VER
    // Define a structure to receive the current Windows filetime
    FILETIME ft;

    // Initialize the present time to 0 and the timezone to UTC
    unsigned __int64 tmpres = 0;
    static int tzflag = 0;

    if (NULL != tv)
    {
        GetSystemTimeAsFileTime(&ft);

        // The GetSystemTimeAsFileTime returns the number of 100 nanosecond
        // intervals since Jan 1, 1601 in a structure. Copy the high bits to
        // the 64 bit tmpres, shift it left by 32 then or in the low 32 bits.
        tmpres |= ft.dwHighDateTime;
        tmpres <<= 32;
        tmpres |= ft.dwLowDateTime;

        // Convert to microseconds by dividing by 10
        tmpres /= 10;

        // The Unix epoch starts on Jan 1 1970.  Need to subtract the difference
        // in seconds from Jan 1 1601.
        tmpres -= DELTA_EPOCH_IN_MICROSECS;

        // Finally change microseconds to seconds and place in the seconds value.
        // The modulus picks up the microseconds.
        tv->tv_sec = (long)(tmpres / 1000000UL);
        tv->tv_usec = (long)(tmpres % 1000000UL);
    }

    if (NULL != tz) {
        if (!tzflag) {
            _tzset();
            tzflag++;
        }

        // Adjust for the timezone west of Greenwich
        tz->tz_minuteswest = _timezone / 60;
        tz->tz_dsttime = _daylight;
    }
#elif !defined(__LCC__)
    double t = clock();
    t /= CLOCKS_PER_SEC;
    tv->tv_sec = (long)(floor(t));
    tv->tv_usec = (long)(floor((t-tv->tv_sec)*1.e6));
#endif

    return 0;
}

#endif

/*-----------------------------------------------------------------------------
 * wtime - Wall-clock time. This function is not thread safe.
 * --------------------------------------------------------------------------*/
double M2C_wtime() {
    double y = -1;

#if !defined(__LCC__)
    struct timeval cur_time;
    gettimeofday(&cur_time, NULL);

    y = (double)(cur_time.tv_sec) + (double)(cur_time.tv_usec)*1.e-6;
#endif

    return (y);
}

#ifndef MATLAB_MEX_FILE
#include <stdarg.h>

/* Issue formatted warning message with corresponding warning identifier */
void M2C_warn(const char * id, const char * msg, ...) {
    va_list args;

    fprintf(stderr, "Warning %s:\n", id);
    va_start(args, msg);
    vfprintf(stderr, msg, args);
    va_end (args);
    fprintf(stderr, "\n");
}

#if defined(M2C_MPI) && M2C_MPI
#include "mpi.h"
#endif

/* Issue formatted error message with corresponding error identifier */
void M2C_error(const char * id, const char * msg, ...) {
    va_list args;

    fprintf(stderr, "Error %s:\n", id);

    va_start(args, msg);
    vfprintf(stderr, msg, args);
    va_end(args);
    fprintf(stderr, "\n");

#if defined(M2C_MPI) && M2C_MPI
    MPI_Abort();
#else
    abort();
#endif
}

#endif


#if (defined(MATLAB_MEX_FILE) || defined(BUILD_MAT)) && !defined(__NVCC__)

#undef malloc
#undef calloc
#undef realloc
#undef free

#endif /* MATLAB_MEX_FILE || BUILD_MAT */
