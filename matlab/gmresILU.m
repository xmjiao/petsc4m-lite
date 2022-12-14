function varargout = gmresILU(varargin)
% Solves a sparse system using GMRES with a right preconditioner
%
% Syntax:
%    x = gmresILU(A, b) solves a sparse linear system using PETSc's GMRES
%    solver with a right preconditioner. Matrix A can be in MATLAB's built-in
%    sparse format or in CRS format with fields 'row_ptr', 'col_inds', and 'vals'.
%    The default preconditioner is ILU0.
%
%    x = gmresILU(A, b, restart)
%    allows you to specify the restart parameter for GMRES. The default
%    value is 30. You can preserve the default value by passing [].
%
%    x = gmresILU(A, b, restart, rtol, maxiter)
%    allows you to specify the relative tolerance and the maximum number
%    of iterations. Their default values are 1.e-5 and 10000, respectively.
%    Use 0 or [] to preserve default values of rtol and maxiter.
%
%    x = gmresILU(A, b, restart, rtol, maxiter, x0)
%    takes an initial solution in x0. Use 0 or [] to preserve the default
%    initial solution (all zeros).
%
%    x = gmresILU(A, b, restart, rtol, maxiter, x0, opts)
%    allows you to specify additional options in a string.
%
%    [x, flag, relres, iter, reshis, times] = gmresILU(___)
%    returns the solution vector x, the flag (KSPConvergedReason), relative
%    residual, number of iterations, history of residual used in convergence
%    test (typically preconditioned residual), and the execution times in
%    setup and solve.
%
% Note: If the low-level function petscSolveCRS is called as a standalone executable,
%       the execution times are  always printed out to the screen.
%
% SEE ALSO: gmresHypre, petscSolveCRS

if nargin == 0
    help gmresILU
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
    opts = [' -ksp_gmres_restart ' int2str(varargin{next_index})];
else
    opts = ' -ksp_gmres_restart 30';
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    rtol = varargin{next_index};
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

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    opts = [opts ' ' varargin{next_index}];
end

[varargout{1:nargout}] = petscSolveCRS(Arows, Acols, PetscScalar(Avals), ...
    PetscScalar(b), PETSC_KSPGMRES, PetscReal(rtol), maxiter, PETSC_PCILU, ...
    PETSC_PC_RIGHT, PetscScalar(x0), opts);

end

function test %#ok<DEFNU>
%!test
%! if exist('OCTAVE_VERSION', 'builtin'); n = 20; else; n = 256; end
%! A = gallery('wathen', n, n);
%! b = A * ones(length(A), 1);
%! rtol = 10*eps(class(PetscReal(0))).^(1/2);

%! [x,flag,relres,iter,reshis,times] = gmresILU(A, b, [], rtol);
%! assert(norm(b - A*double(x)) < rtol * norm(b))
%! fprintf('gmresILU setup took %g seconds and solver took %g seconds\n', times(1), times(2));

end
