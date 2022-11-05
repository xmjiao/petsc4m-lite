function val = PETSC_PCGASM% Obtain PETSC constant PCGASM

coder.inline('always');

val = petscGetString('PCGASM');
end
