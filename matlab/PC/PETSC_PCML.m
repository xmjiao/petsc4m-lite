function val = PETSC_PCML% Obtain PETSC constant PCML

coder.inline('always');

val = petscGetString('PCML');
end
