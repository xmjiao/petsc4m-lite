function val = PETSC_PCJACOBI% Obtain PETSC constant PCJACOBI

coder.inline('always');

val = petscGetString('PCJACOBI');
end
