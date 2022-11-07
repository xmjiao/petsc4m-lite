#include "crs_createFromAIJ.h"
#include "m2c.h"
#include "crs_createFromAIJ_types.h"

static void crs_sort(const emxArray_int32_T *row_ptr, emxArray_int32_T *col_ind,
                     emxArray_real_T *val);

static void crs_sort(const emxArray_int32_T *row_ptr, emxArray_int32_T *col_ind,
                     emxArray_real_T *val)
{
  emxArray_int32_T *buf_indx;
  emxArray_real_T *buf_val;
  double t0;
  int b_i;
  int c_i;
  int exitg1;
  int exitg2;
  int i;
  int ir;
  int j;
  int l;
  int r0;
  boolean_T ascend;
  boolean_T guard1 = false;
  boolean_T guard2 = false;
  i = row_ptr->size[0];
  emxInit_real_T(&buf_val, 1);
  emxInit_int32_T(&buf_indx, 1);
  for (b_i = 0; b_i <= i - 2; b_i++) {
    ascend = true;
    j = row_ptr->data[b_i];
    do {
      exitg1 = 0;
      r0 = row_ptr->data[b_i + 1];
      if (j + 1 <= r0 - 1) {
        if (col_ind->data[j] < col_ind->data[j - 1]) {
          ascend = false;
          exitg1 = 1;
        } else {
          j++;
        }
      } else {
        exitg1 = 1;
      }
    } while (exitg1 == 0);
    if (!ascend) {
      l = r0 - row_ptr->data[b_i];
      r0 = buf_indx->size[0];
      buf_indx->size[0] = l;
      emxEnsureCapacity_int32_T(buf_indx, r0);
      for (r0 = 0; r0 < l; r0++) {
        buf_indx->data[r0] = 0;
      }
      r0 = buf_val->size[0];
      buf_val->size[0] = l;
      emxEnsureCapacity_real_T(buf_val, r0);
      for (r0 = 0; r0 < l; r0++) {
        buf_val->data[r0] = 0.0;
      }
      r0 = row_ptr->data[b_i];
      ir = row_ptr->data[b_i + 1] - 1;
      for (j = r0; j <= ir; j++) {
        l = (int)((unsigned int)j - r0);
        buf_indx->data[l] = col_ind->data[j - 1];
        buf_val->data[l] = val->data[j - 1];
      }
      if (buf_indx->size[0] > 1) {
        l = (int)((unsigned int)buf_indx->size[0] >> 1);
        ir = buf_indx->size[0];
        do {
          exitg1 = 0;
          guard1 = false;
          if (l + 1 <= 1) {
            r0 = buf_indx->data[ir - 1];
            t0 = buf_val->data[ir - 1];
            buf_indx->data[ir - 1] = buf_indx->data[0];
            buf_val->data[ir - 1] = buf_val->data[0];
            ir--;
            if (ir == 1) {
              exitg1 = 1;
            } else {
              guard1 = true;
            }
          } else {
            l--;
            r0 = buf_indx->data[l];
            t0 = buf_val->data[l];
            guard1 = true;
          }
          if (guard1) {
            j = l;
            do {
              exitg2 = 0;
              c_i = j;
              j = ((j + 1) << 1) - 1;
              ascend = false;
              guard2 = false;
              if (j + 1 >= ir) {
                if (j + 1 == ir) {
                  ascend = true;
                  guard2 = true;
                } else if (j + 1 > ir) {
                  exitg2 = 1;
                } else {
                  guard2 = true;
                }
              } else {
                guard2 = true;
              }
              if (guard2) {
                if ((!ascend) && (buf_indx->data[j] < buf_indx->data[j + 1])) {
                  j++;
                }
                if (r0 >= buf_indx->data[j]) {
                  exitg2 = 1;
                } else {
                  buf_indx->data[c_i] = buf_indx->data[j];
                  buf_val->data[c_i] = buf_val->data[j];
                }
              }
            } while (exitg2 == 0);
            buf_indx->data[c_i] = r0;
            buf_val->data[c_i] = t0;
          }
        } while (exitg1 == 0);
        buf_indx->data[0] = r0;
        buf_val->data[0] = t0;
      }
      r0 = row_ptr->data[b_i];
      ir = row_ptr->data[b_i + 1] - 1;
      for (j = r0; j <= ir; j++) {
        l = (int)((unsigned int)j - r0);
        col_ind->data[j - 1] = buf_indx->data[l];
        val->data[j - 1] = buf_val->data[l];
      }
    }
  }
  emxFree_int32_T(&buf_indx);
  emxFree_real_T(&buf_val);
}

void crs_create1(const emxArray_int32_T *is, const emxArray_int32_T *js,
                 const emxArray_real_T *vs, int ni, int nj, struct0_T *A)
{
  int b_i;
  int c_i;
  int i;
  int loop_ub;
  boolean_T ascend;
  boolean_T exitg1;
  A->ncols = nj;
  i = A->row_ptr->size[0];
  A->row_ptr->size[0] = ni + 1;
  emxEnsureCapacity_int32_T(A->row_ptr, i);
  for (i = 0; i <= ni; i++) {
    A->row_ptr->data[i] = 0;
  }
  i = A->col_ind->size[0];
  A->col_ind->size[0] = js->size[0];
  emxEnsureCapacity_int32_T(A->col_ind, i);
  loop_ub = js->size[0];
  for (i = 0; i < loop_ub; i++) {
    A->col_ind->data[i] = 0;
  }
  i = A->val->size[0];
  A->val->size[0] = js->size[0];
  emxEnsureCapacity_real_T(A->val, i);
  loop_ub = js->size[0];
  for (i = 0; i < loop_ub; i++) {
    A->val->data[i] = 0.0;
  }
  A->nrows = ni;
  i = is->size[0];
  for (b_i = 0; b_i < i; b_i++) {
    A->row_ptr->data[is->data[b_i]]++;
  }
  A->row_ptr->data[0] = 1;
  for (b_i = 0; b_i < ni; b_i++) {
    A->row_ptr->data[b_i + 1] += A->row_ptr->data[b_i];
  }
  ascend = true;
  b_i = 0;
  exitg1 = false;
  while ((!exitg1) && (b_i <= is->size[0] - 2)) {
    if (is->data[b_i + 1] < is->data[b_i]) {
      ascend = false;
      exitg1 = true;
    } else {
      b_i++;
    }
  }
  if (ascend) {
    i = A->col_ind->size[0];
    A->col_ind->size[0] = js->size[0];
    emxEnsureCapacity_int32_T(A->col_ind, i);
    loop_ub = js->size[0];
    for (i = 0; i < loop_ub; i++) {
      A->col_ind->data[i] = js->data[i];
    }
    i = A->val->size[0];
    A->val->size[0] = vs->size[0];
    emxEnsureCapacity_real_T(A->val, i);
    loop_ub = vs->size[0];
    for (i = 0; i < loop_ub; i++) {
      A->val->data[i] = vs->data[i];
    }
  } else {
    i = A->col_ind->size[0];
    A->col_ind->size[0] = js->size[0];
    emxEnsureCapacity_int32_T(A->col_ind, i);
    i = A->val->size[0];
    A->val->size[0] = js->size[0];
    emxEnsureCapacity_real_T(A->val, i);
    i = is->size[0];
    for (b_i = 0; b_i < i; b_i++) {
      loop_ub = A->row_ptr->data[is->data[b_i] - 1];
      A->val->data[loop_ub - 1] = vs->data[b_i];
      A->col_ind->data[loop_ub - 1] = js->data[b_i];
      A->row_ptr->data[is->data[b_i] - 1] = loop_ub + 1;
    }
    i = A->row_ptr->size[0] - 2;
    loop_ub = (int)(((-1.0 - (double)A->row_ptr->size[0]) + 2.0) / -1.0);
    for (b_i = 0; b_i < loop_ub; b_i++) {
      c_i = i - b_i;
      A->row_ptr->data[c_i + 1] = A->row_ptr->data[c_i];
    }
    A->row_ptr->data[0] = 1;
  }
  crs_sort(A->row_ptr, A->col_ind, A->val);
}

void crs_createFromAIJ(const emxArray_int32_T *rows,
                       const emxArray_int32_T *cols, const emxArray_real_T *vs,
                       struct0_T *A)
{
  int ex;
  int i;
  int istop;
  int k;
  int nrows;
  boolean_T ascend;
  boolean_T exitg1;
  istop = rows->size[0];
  nrows = 0;
  if (rows->size[0] >= 1) {
    nrows = rows->data[0];
    for (k = 2; k <= istop; k++) {
      i = rows->data[k - 1];
      if (nrows < i) {
        nrows = i;
      }
    }
  }
  istop = cols->size[0];
  ex = 0;
  if (cols->size[0] >= 1) {
    ex = cols->data[0];
    for (k = 2; k <= istop; k++) {
      i = cols->data[k - 1];
      if (ex < i) {
        ex = i;
      }
    }
  }
  A->ncols = ex;
  i = A->row_ptr->size[0];
  A->row_ptr->size[0] = nrows + 1;
  emxEnsureCapacity_int32_T(A->row_ptr, i);
  for (i = 0; i <= nrows; i++) {
    A->row_ptr->data[i] = 0;
  }
  i = A->col_ind->size[0];
  A->col_ind->size[0] = cols->size[0];
  emxEnsureCapacity_int32_T(A->col_ind, i);
  istop = cols->size[0];
  for (i = 0; i < istop; i++) {
    A->col_ind->data[i] = 0;
  }
  i = A->val->size[0];
  A->val->size[0] = cols->size[0];
  emxEnsureCapacity_real_T(A->val, i);
  istop = cols->size[0];
  for (i = 0; i < istop; i++) {
    A->val->data[i] = 0.0;
  }
  A->nrows = nrows;
  i = rows->size[0];
  for (k = 0; k < i; k++) {
    A->row_ptr->data[rows->data[k]]++;
  }
  A->row_ptr->data[0] = 1;
  for (k = 0; k < nrows; k++) {
    A->row_ptr->data[k + 1] += A->row_ptr->data[k];
  }
  ascend = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= rows->size[0] - 2)) {
    if (rows->data[k + 1] < rows->data[k]) {
      ascend = false;
      exitg1 = true;
    } else {
      k++;
    }
  }
  if (ascend) {
    i = A->col_ind->size[0];
    A->col_ind->size[0] = cols->size[0];
    emxEnsureCapacity_int32_T(A->col_ind, i);
    istop = cols->size[0];
    for (i = 0; i < istop; i++) {
      A->col_ind->data[i] = cols->data[i];
    }
    i = A->val->size[0];
    A->val->size[0] = vs->size[0];
    emxEnsureCapacity_real_T(A->val, i);
    istop = vs->size[0];
    for (i = 0; i < istop; i++) {
      A->val->data[i] = vs->data[i];
    }
  } else {
    i = A->col_ind->size[0];
    A->col_ind->size[0] = cols->size[0];
    emxEnsureCapacity_int32_T(A->col_ind, i);
    i = A->val->size[0];
    A->val->size[0] = cols->size[0];
    emxEnsureCapacity_real_T(A->val, i);
    i = rows->size[0];
    for (k = 0; k < i; k++) {
      istop = A->row_ptr->data[rows->data[k] - 1];
      A->val->data[istop - 1] = vs->data[k];
      A->col_ind->data[istop - 1] = cols->data[k];
      A->row_ptr->data[rows->data[k] - 1] = istop + 1;
    }
    i = A->row_ptr->size[0] - 2;
    istop = (int)(((-1.0 - (double)A->row_ptr->size[0]) + 2.0) / -1.0);
    for (k = 0; k < istop; k++) {
      ex = i - k;
      A->row_ptr->data[ex + 1] = A->row_ptr->data[ex];
    }
    A->row_ptr->data[0] = 1;
  }
  crs_sort(A->row_ptr, A->col_ind, A->val);
}

void crs_createFromAIJ_initialize(void)
{
}

void crs_createFromAIJ_terminate(void)
{
}
