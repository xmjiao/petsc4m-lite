function val = PETSC_PCLU% Obtain PETSC constant PCLU

coder.inline('always');

val = petscGetString('PCLU');
end
