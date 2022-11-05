function val = PETSC_MATSOLVERSUPERLU_DIST% Obtain PETSC constant MATSOLVERSUPERLU_DIST

coder.inline('always');

val = petscGetString('MATSOLVERSUPERLU_DIST');
end
