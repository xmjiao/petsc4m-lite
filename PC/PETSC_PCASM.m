function val = PETSC_PCASM% Obtain PETSC constant PCASM

coder.inline('always');

val = petscGetString('PCASM');
end
