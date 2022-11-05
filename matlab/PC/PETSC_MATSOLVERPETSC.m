function val = PETSC_MATSOLVERPETSC% Obtain PETSC constant MATSOLVERPETSC

coder.inline('always');

val = petscGetString('MATSOLVERPETSC');
end
