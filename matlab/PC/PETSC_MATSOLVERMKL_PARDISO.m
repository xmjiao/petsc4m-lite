function val = PETSC_MATSOLVERMKL_PARDISO% Obtain PETSC constant MATSOLVERMKL_PARDISO

coder.inline('always');

val = petscGetString('MATSOLVERMKL_PARDISO');
end
