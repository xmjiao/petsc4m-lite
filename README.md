OVERVIEW
========

petsc4m-lite is an interface of PETSc for MATLAB and GNU Octave on Linux or MacOSX.
Its main top-level function is `petscSolve`, which uses the direct solver MUMPS by
default but can be configured to call any combination of solves and preconditioners
available in PETSc. For convenience, petsc4m-lite provides two additional top-level
functions, `gmresILU` and `gmresHypre`, which use ILU0 and BoomerAMG as right
preconditioners, respectively. In all cases, the true residuals are used for the
convergence criteria. The inputs matrices can be either a MATLAB `sparse` matrix or
a CRS `struct` containing `row_ptr`, `col_ind`, and `vals` fields.

EXAMPLE
=======

The following example illustrates how to use `gmresILU`:
```
  A = gallery('wathen', 10, 10);
  b = A * ones(length(A), 1);
  rtol = 10*eps(class(PetscReal(0))).^(1/2);
  [x,flag,relres,iter,reshis,times] = gmresILU(A, b, [], rtol);
```

SETTING UP PETSC4M-LITE
=======================

petsc4m-lite requires PETSc. A recommended approach for installing PETSc
is to use `miniconda3` (or `anaconda3`), since it has the most up-to-date
version of PETSc. Suppose you have already installed either `miniconda3`
or `anaconda3` and have `conda` in the path and the environment variable
`CONDA_PREFIX` pointing to the correct version, you can install PETSc
using the command
```
   conda install -y -c conda-forge petsc=3.18.1
```

On Linux systems, you can also use the older versions of PETSc that comes with
your Linux distribution if you have system-administration access. For example,
on Ubuntu 22.04, you can install PETSc using the command
```
  sudo apt update
  sudo apt install -y petsc-dev
```

Of course, you can also install PETSc yourself and define the environnement
variable `PETSC_DIR`. petsc-lite tries to locate the PETSc installation in the
following order:

1) root path of PETSc specified by the environment variable `PETSC_DIR`;
2) installation with Anaconda/Miniconda with environment variable `CONDA_PREFIX`;
3) System installation under `/usr/lib/petsc` (such as on Ubuntu).


NOTES ON PETSC4M-LITE IN MATLAB
===============================

When running MATLAB on Linux or with JAVA enabled, petsc4m-lite pass data through
files between MATLAB and PETSc for robustness. However, on MacOSX, data will be
passed through memory when MATLAB is started without Java using the command
```
matlab -nojvm
```
This may be better for solving large systems. On Linux systems, unfortunately,
your only option would be to use Octave (see below).

NOTES ON PETSC4M-LITE IN OCTAVE
===============================

PETSC4M-LITE works with Octave on Linux and Mac. In this case, data is passed
through memory. It is recommended that you install Octave using Miniconda.
