function val = PETSC_PCBICGSTABCUSP% Obtain PETSC constant PCBICGSTABCUSP

coder.inline('always');

val = petscGetString('PCBICGSTABCUSP');
end
