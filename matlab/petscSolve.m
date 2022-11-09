function varargout = petscSolve(varargin)
% Solves a sparse system using any PETSc solver and conditioner combination.
%
% Syntax:
%    x = petscSolve(A, b)
%    solves a sparse linear system using the direct solver MUMPS. Matrix A
%    can be in MATLAB's built-in sparse format or in CRS format with fields
%    'row_ptr', 'col_inds', and 'vals'.
%
%    x = petscSolve(A, b, solver)
%    x = petscSolve(A, b, solver, pctype)
%    x = petscSolve(A, b, solver, pctype, opts)
%    allows you to specify an alternative solver, (such as PETSC_KSPBCGS),
%    preconditioners (such as PETSC_PCHYPRE), and additional options
%    such as '-pc_hypre_boomeramg_coarsen_type HMIS'). For iterative
%    methods, it will use PETSc's default values for rtol and maxiter,
%    which are 1.e-5 and 10000, respectively.
%
%    x = petscSolve(A, b, solver, pctype, opts, rtol)
%    x = petscSolve(A, b, solver, pctype, opts, rtol, maxiter)
%    x = petscSolve(A, b, solver, pctype, opts, rtol, maxiter, x0)
%    allows you to specify the relative tolerance, the maximum number
%    of iterations (maxiter), and an initial guess x0. You can use 0 or []
%    to preserve the default values and initial solution (all zeros).
%
%    [x, flag, relres, iter, reshis, times] = petscSolve(___)
%    returns the solution vector x, the flag (KSPConvergedReason), relative
%    residual, number of iterations, history of residual used in convergence
%    test (typically preconditioned residual), and the execution times in
%    setup and solve.
%
% Note: If the low-level function petscSolveCRS is called as a standalone
%       executable, the execution times are  always printed out to the screen.
%
% SEE ALSO: gmresILU, gmresHypre, petscSolveCRS

if nargin == 0
    help petscSolve
    return;
end

if issparse(varargin{1})
    [Arows, Acols, Avals] = crs_matrix(varargin{1});
else
    assert(isstruct(varargin{1}));
    Arows = int32(varargin{1}.row_ptr);
    Acols = int32(varargin{1}.col_ind);
    Avals = PetscScalar(varargin{1}.val);
end

next_index = 2;

if nargin < next_index
    error('The right hand-side must be specified');
else
    b = varargin{next_index};
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    solver = varargin{next_index};
else
    solver = PETSC_KSPPREONLY;
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    pctype = varargin{next_index};
    opts = '';
elseif ~strcmp(solver, PETSC_KSPPREONLY)
    pctype = PETSC_PCILU;
    opts = '';
else
    pctype = PETSC_PCLU;
    opts = '-pc_factor_mat_solver_type mumps';
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    opts = [opts ' ' varargin{next_index}];
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    rtol = varargin{next_index};
elseif strcmp(solver, PETSC_KSPPREONLY) && strcmp(pctype, PETSC_PCLU)
    rtol = PetscReal(1.e-16);
else
    rtol = PetscReal(0);
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    maxiter = int32(varargin{next_index});
else
    maxiter = int32(0);
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    x0 = varargin{next_index};
else
    x0 = PetscScalar(zeros(0, 1));
end

[varargout{1:nargout}] = petscSolveCRS(Arows, Acols, PetscScalar(Avals), ...
    PetscScalar(b), solver, PetscReal(rtol), maxiter, pctype, '', PetscScalar(x0), opts);
end

function test %#ok<DEFNU>
%!test
%! if exist('OCTAVE_VERSION', 'builtin'); n = 20; else; n = 256; end
%! A = gallery('wathen', n, n);
%! b = A * ones(length(A), 1);
%! rtol = 1.e-12;

%! [x,flag,relres,iter,reshis,times] = petscSolve(A, b);
%! assert(norm(b - A*double(x)) < 1.e-10 * norm(b))
%! fprintf('mumps setup took %g seconds and solver took %g seconds\n', times(1), times(2));

end
