function val = PETSC_KSPFBCGS% Obtain PETSC constant KSPFBCGS

coder.inline('always');

val = petscGetString('KSPFBCGS');
end
