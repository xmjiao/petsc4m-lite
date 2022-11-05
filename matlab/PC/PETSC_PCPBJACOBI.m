function val = PETSC_PCPBJACOBI
% Obtain PETSC constant PCPBJACOBI

coder.inline('always');

val = 'cpbjacobi';
end
