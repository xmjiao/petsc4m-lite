function val = PETSC_PCAINVCUSP% Obtain PETSC constant PCAINVCUSP

coder.inline('always');

val = petscGetString('PCAINVCUSP');
end
