function val = PETSC_KSPLSQR
% Obtain PETSC constant KSPLSQR

coder.inline('always');

val = 'splsqr';
end
