function val = PETSC_KSPBCGS% Obtain PETSC constant KSPBCGS

coder.inline('always');

val = petscGetString('KSPBCGS');
end
