function val = PETSC_PCICC% Obtain PETSC constant PCICC

coder.inline('always');

val = petscGetString('PCICC');
end
