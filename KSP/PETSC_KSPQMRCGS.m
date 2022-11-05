function val = PETSC_KSPQMRCGS% Obtain PETSC constant KSPFQMRCGS

coder.inline('always');

val = petscGetString('KSPQMRCGS');
end
