function val = PETSC_MATSOLVERSUPERLU% Obtain PETSC constant MATSOLVERSUPERLU

coder.inline('always');

val = petscGetString('MATSOLVERSUPERLU');
end
