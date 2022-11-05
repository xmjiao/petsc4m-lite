function val = PETSC_PCGAMG% Obtain PETSC constant PCGAMG

coder.inline('always');

val = petscGetString('PCGAMG');
end
