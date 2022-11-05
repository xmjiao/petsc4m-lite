function val = PETSC_PCCOMPOSITE% Obtain PETSC constant PCCOMPOSITE

coder.inline('always');

val = petscGetString('PCCOMPOSITE');
end
