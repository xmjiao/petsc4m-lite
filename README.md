OVERVIEW
========

petsc4m-lite is an interface of PETSc for MATLAB and GNU Octave on Linux or MacOSX.
Data exchanges are done through memory whenever possible, or through files if PETSc is
prone to crashing (e.g., when running MATLAB in the desktop environment). There are
two main top-level functions: `gmresPetsc` and `gmresHypre`. The former uses
ILU0 as preconditioner, and the latter uses BoomerAMG in Hypre as preconditioner.
Both solvers use right-preconditioning, so that the true residuals are used for
the convergence criteria. Their inputs can be either MATLAB `sparse` or a CRS
`struct`. These functions can be easily adapted to use other KSP solvers and
preconditioners supported by PETSc, except that PETSc may not use the true
residual as the convergence tolerance in most cases (such as bicgstab even
with right-preconditionning).

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

petsc4m-lite requires PETSc. A recommended approach for installing PETSc
is to use `miniconda3` (or `anaconda3`), since it has the most up-to-date
version of PETSc. Suppose you have already installed either `miniconda3`
or `anaconda3` and have `conda` in the path and the environment variable
`CONDA_PREFIX` pointing to the correct version, you can install PETSc
using the command
```
   conda install -y -c conda-forge petsc
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

When running MATLAB in desktop mode, petsc4m-lite always pass data through
files for robustness. When solving larger systems in MATLAB, you may prefer to
pass data through memory. In this case, you can opt to use Octave. If you must
use MATLAB, you need to take some extra steps to resolve potential conflicts
of the LAPACK and MPI libraries used by MATLAB and PETSc. In particular, you need to

1) disable the desktop environment when launching MATLAB,
2) tell MATLAB to preload the LAPACK shared library used by PETSc on Linux systems, and
3) tell MATLAB to preload the MPICH libraries used by the Parallel Computing Toolbox
  on Linux systems if you have installed the Toolbox of MATLAB and the PETSc library
  was linked with a binary-compatible variant of MPICH.

For example, on Mac OS X, you imply need to run `matlab` using command
```
matlab -nodesktop
```

On Linux, if PETSc was installed using Anaconda/Miniconda on Linux, which does use
MPICH, you need to to start MATLAB with the following command:

```
LD_PRELOAD=$CONDA_PREFIX/lib/liblapack.so.3:$MATLAB_ROOT/bin/glnxa64/libmpi.so.12:$MATLAB_ROOT/bin/glnxa64/libmpifort.so.12 matlab -nodesktop
```

where `$CONDA_PREFIX` is typically `$HOME/opt/anaconda3` or `$HOME/opt/miniconda3`
and `$MATLAB_ROOT` is typically `/usr/local/MATLAB/$MATMAB_VERSION` for your
specific MATLAB version.

If you use the PETSc library distributed with Ubuntu, which uses OpenMPI, then
you only need to preload LAPACK as follows:
```
LD_PRELOAD=/lib/x86_64-linux-gnu/liblapack.so.3 matlab -nodesktop
```
For your own installation of PETSc on Linux, you can find out the LAPACK library
used by PETSc using the command `ldd /path/to/libpetsc*.so | grep lapack`. If you
are unsure whether PETSc was built using an MPICH variant, it is safe to preload
the MPI libraries.
