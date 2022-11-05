function val = PETSC_KSPTFQMR% Obtain PETSC constant KSPTFQMR

coder.inline('always');

val = petscGetString('KSPTFQMR');
end
