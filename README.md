OVERVIEW
========

`petsc4m-lite` is an interface of sequential PETSc for MATLAB and GNU Octave.
Data exchanges between PETSc and MATLAB are either through files (if running
with JVM due to some conflicts) or through memory (if running without JVM).
Data exchange between PETSc and Pctave is through memory. Hence, it can
be used to solve intermediate-scale sparse linear systems in MATLAB and
large-scale problems in Octave.

The two top-level functions are `gmresPetsc` and `gmresHypre`. The former
uses ILU0 as preconditioner, and the latter uses BoomerAMG as preconditioner.
Both solvers use right-preconditioning, so that the true residuals are always
reported. Their inputs can be either MATLAB `sparse` or a CRS `struct`.
These scripts can be easily adapted to use other KSP solvers and preconditioners
supported by PETSc. However, PETSc does not use the true residual as the
convergence tolerance for almost all other KSP solvers (such as bicgstab),
although it can monitor the true residual.

EXAMPLE
=======

The following example illustrates how to use `gmresPetsc`:
```
  A = gallery('wathen', 10, 10);
  b = A * ones(length(A), 1);
  rtol = 10*eps(class(PetscReal(0))).^(1/2);

  [x,flag,relres,iter,reshis,times] = gmresPetsc(A, b, [], rtol);
```

SETTING UP PETSC4M-LITE
=======================

petsc4m-lite requires PETSc, and it supports both Linux and Mac OS X.
It will try to find the PETSc installation in the following order:
 - Installation with the environment variable `PETSC_DIR`;
 - Installation with Anaconda/Miniconda with environment variable `CONDA_PREFIX`;
 - System installation under `/usr/lib/petsc`.

NOTES ON PETSC4M-LITE IN MATLAB
===============================

When solving larger systems using MATLAB, you may want to pass data
through memory instead of files. In this case, you must preload BLAS
and LAPACK libraries and also disable JAVA virtual machine. For example,
```
LD_PRELOAD=/path/to/blas/libblas.so:/path/to/lapack/liblapack.so matlab -nojvm
```

You can find out the blas and lapack libaries used by PETSc by running
the command `ldd /path/to/libpetsc*.so`.
