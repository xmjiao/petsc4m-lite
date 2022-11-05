#ifndef PETSCSOLVECRS_EMXAPI_H
#define PETSCSOLVECRS_EMXAPI_H

#include "petscSolveCRS_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

extern emxArray_char_T *emxCreateND_char_T(int numDimensions, const int *size);

extern emxArray_int32_T *emxCreateND_int32_T(int numDimensions,
                                             const int *size);

extern emxArray_real_T *emxCreateND_real_T(int numDimensions, const int *size);

extern emxArray_char_T *emxCreateWrapperND_char_T(char *data, int numDimensions,
                                                  const int *size);

extern emxArray_int32_T *
emxCreateWrapperND_int32_T(int *data, int numDimensions, const int *size);

extern emxArray_real_T *
emxCreateWrapperND_real_T(double *data, int numDimensions, const int *size);

extern emxArray_char_T *emxCreateWrapper_char_T(char *data, int rows, int cols);

extern emxArray_int32_T *emxCreateWrapper_int32_T(int *data, int rows,
                                                  int cols);

extern emxArray_real_T *emxCreateWrapper_real_T(double *data, int rows,
                                                int cols);

extern emxArray_char_T *emxCreate_char_T(int rows, int cols);

extern emxArray_int32_T *emxCreate_int32_T(int rows, int cols);

extern emxArray_real_T *emxCreate_real_T(int rows, int cols);

extern void emxDestroyArray_char_T(emxArray_char_T *emxArray);

extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);

extern void emxDestroyArray_real_T(emxArray_real_T *emxArray);

extern void emxInitArray_char_T(emxArray_char_T **pEmxArray, int numDimensions);

extern void emxInitArray_int32_T(emxArray_int32_T **pEmxArray,
                                 int numDimensions);

extern void emxInitArray_real_T(emxArray_real_T **pEmxArray, int numDimensions);

#ifdef __cplusplus
}
#endif

#endif
