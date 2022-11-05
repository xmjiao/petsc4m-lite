function val = PETSC_PCSACUSP% Obtain PETSC constant PCSACUSP

coder.inline('always');

val = petscGetString('PCSACUSP');
end
