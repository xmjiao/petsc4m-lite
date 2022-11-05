function val = PETSC_MATSOLVERUMFPACK% Obtain PETSC constant MATSOLVERUMFPACK

coder.inline('always');

val = petscGetString('MATSOLVERUMFPACK');
end
