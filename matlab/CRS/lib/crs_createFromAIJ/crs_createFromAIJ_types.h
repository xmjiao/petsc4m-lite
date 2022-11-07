#ifndef CRS_CREATEFROMAIJ_TYPES_H
#define CRS_CREATEFROMAIJ_TYPES_H

#include "rtwtypes.h"

#ifndef struct_emxArray_int32_T
#define struct_emxArray_int32_T
struct emxArray_int32_T {
  int *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};
#endif
#ifndef typedef_emxArray_int32_T
#define typedef_emxArray_int32_T
typedef struct emxArray_int32_T emxArray_int32_T;
#endif

#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T
struct emxArray_real_T {
  double *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};
#endif
#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T
typedef struct emxArray_real_T emxArray_real_T;
#endif

#ifndef typedef_struct0_T
#define typedef_struct0_T
typedef struct {
  emxArray_int32_T *row_ptr;
  emxArray_int32_T *col_ind;
  emxArray_real_T *val;
  int nrows;
  int ncols;
} struct0_T;
#endif

#endif
