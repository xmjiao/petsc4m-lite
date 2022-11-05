function val = PETSC_PCSPAI% Obtain PETSC constant PCSPAI

coder.inline('always');

val = petscGetString('PCSPAI');
end
