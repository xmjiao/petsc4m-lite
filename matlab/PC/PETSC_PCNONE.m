function val = PETSC_PCNONE% Obtain PETSC constant PCNONE

coder.inline('always');

val = petscGetString('PCNONE');
end
