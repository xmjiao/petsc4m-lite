function val = PETSC_PCSOR% Obtain PETSC constant PCSOR

coder.inline('always');

val = petscGetString('PCSOR');
end
