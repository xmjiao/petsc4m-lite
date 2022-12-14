function varargout = gmresHypre(varargin)
% Solves a sparse system using GMRES with BoomerAMG as right preconditioner
%
% Syntax:
%    x = gmresHypre(A, b) solves a sparse linear system using PETSc's GMRES
%    solver with Hypre's BoomerAMG as the right preconditioner. Matrix A can be in
%    MATLAB's built-in sparse format or in CRS format created using crs_matrix.
%    By default, HMIS coarsening and FF1 interpolation are used with Hypre.
%
%    x = gmresHypre(A, b, restart)
%    allows you to specify the restart parameter for GMRES. The default
%    value is 30. You can preserve the default value by passing [].
%
%    x = gmresHypre(A, b, restart, rtol, maxiter)
%    allows you to specify the relative tolerance and the maximum number
%    of iterations. Their default values are 1.e-5 and 10000, respectively.
%    Use 0 or [] to preserve default values of rtol and maxiter.
%
%    x = gmresHypre(A, b, restart, rtol, maxiter, x0)
%    takes an initial solution in x0. Use 0 or [] to preserve the default
%    initial solution (all zeros).
%
%    x = gmresHypre(A, b, restart, rtol, maxiter, x0, coarsen, interp)
%    allows you to specify different coarsening and interpolation
%    strategies for BoomerAMG.
%
%    x = gmresHypre(A, b, restart, rtol, maxiter, x0, coarsen, interp, smoother)
%    allows you to specify different types of smoothing strategies for BoomerAMG.
%
%    The available coarsening strategies include:
%    - 'HMIS'. This works well for both 2-D and 3-D, so it is the default.
%    - 'PMIS'. It has similar performance as HMIS.
%    - 'Falgout'. This is the default in BoomerAMG, but it works well only
%            for 2-D problems. The recommended interpolation is 'classical'.
%    - Others: 'CLJP', 'Ruge-Stueben', 'modifiedRuge-Stueben'.
%
%    The interpolation strategy can be one of the following (default is ext+i):
%    - 'classical': Recommended for Falgout coarsening.
%    - 'FF1': Recommended for HMIS and PMIS coarsening.
%    - Others: 'direct', 'multipass', 'multipass-wts', 'ext+i',
%              'ext+i-cc', 'standard', 'standard-wts',
%              'block', 'block-wtd', 'FF', 'ext',
%              'ad-wts', 'ext-mm', 'ext+i-mm', 'ext+e-mm'
%
%    The smoother can be one of the following types (default is 'l1-Gauss-Seidel'):
%    - Basic relaxation-type smoother:
%       'Jacobi','sequential-Gauss-Seidel','seqboundary-Gauss-Seidel',
%       'SOR/Jacobi','backward-SOR/Jacobi', 'symmetric-SOR/Jacobi',
%       'l1scaled-SOR/Jacobi', 'Gaussian-elimination',
%       'l1-Gauss-Seidel', 'backward-l1-Gauss-Seidel',
%       'CG', 'Chebyshev','FCF-Jacobi','l1scaled-Jacobi'
%    - More complex smoothers:
%       'Schwarz-smoothers', 'Pilut', 'ParaSails', 'Euclid'
%
%    [x, flag, relres, iter, reshis, times] = gmresHypre(...)
%    returns the solution vector x, the flag (KSPConvergedReason), relative
%    residual, number of iterations, history of residual used in convergence
%    test (typically preconditioned residual), and the execution times in
%    setup and solve.
%
% Note: If the low-level function petscSolveCRS is called as a standalone executable,
%       the execution times are  always printed out to the screen.
%
% SEE ALSO: gmresILU, petscSolveCRS

if nargin == 0
    help gmresHypre
    return;
end

if issparse(varargin{1})
    [Arows, Acols, Avals] = crs_matrix(varargin{1});
else
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
    opts = [opts ' -pc_hypre_boomeramg_coarsen_type ' varargin{next_index}];
    % Use the default, which is HMIS
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    opts = [opts ' -pc_hypre_boomeramg_interp_type ' varargin{next_index}];
elseif contains(opts, 'MIS')
    % If user specify HMIS or PMIS, choose FF1 interpolation by default
    opts = [opts ' -pc_hypre_boomeramg_interp_type FF1'];
elseif contains(opts, 'Falgout')
    % If user specified Falgout coarsening, choose classical interpolation by default
    opts = [opts ' -pc_hypre_boomeramg_interp_type classical'];
else
    % Use the default, which is extended+i interpolation
end

next_index = next_index + 1;
if nargin >= next_index && ~isempty(varargin{next_index})
    switch varargin{next_index}
        case {'Schwarz-smoothers', 'Pilut', 'ParaSails', 'Euclid'}
            opts = [opts ' -pc_hypre_boomeramg_smooth_type ' varargin{next_index}];
        otherwise
            opts = [opts ' -pc_hypre_boomeramg_relax_type_all ' varargin{next_index}];
    end
else
    % Use the default, which is l1-Gauss-Seidel
end

[varargout{1:nargout}] = petscSolveCRS(Arows, Acols, PetscScalar(Avals), ...
    PetscScalar(b), PETSC_KSPGMRES, PetscReal(rtol), maxiter, PETSC_PCHYPRE, ...
    PETSC_PC_RIGHT, PetscScalar(x0), opts);
end

function test %#ok<DEFNU>
%!test
%! if exist('OCTAVE_VERSION', 'builtin'); n = 20; else; n = 256; end
%! A = gallery('wathen', n, n);
%! b = A * ones(length(A), 1);
%! rtol = 10*eps(class(PetscReal(0))).^(1/2);

%! [x,flag,relres,iter,reshis,times] = gmresHypre(A, b, [], rtol);
%! assert(norm(b - A*double(x)) < rtol * norm(b))
%! fprintf('gmresHypre setup took %g seconds and solver took %g seconds\n', times(1), times(2));

end
