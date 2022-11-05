function val = PETSC_PCPFMG% Obtain PETSC constant PCPFMG

coder.inline('always');

val = petscGetString('PCPFMG');
end
