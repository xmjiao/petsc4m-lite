function val = PETSC_PCGALERKIN% Obtain PETSC constant PCGALERKIN

coder.inline('always');

val = petscGetString('PCGALERKIN');
end
