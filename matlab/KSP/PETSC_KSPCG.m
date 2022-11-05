function val = PETSC_KSPCG
% Obtain PETSC constant KSPCG

coder.inline('always');

val = 'spcg';
end
