function init_petsc(varargin)
%INIT_PETSC Load Petsc4m-Lite into MATLAB/Octave for execution using mex files.

if ~use_mexfiles; return; end

addpath(fullfile(petsc4m_root, 'sys'));

if exist(['petscInitialize.' mexext], 'file') && ...
    isequal(which('petscInitialize'), which(['petscInitialize.' mexext]))
    try
        if ~petscInitialized
            petscInitialize;

            if exist('OCTAVE_VERSION', 'builtin')
                atexit('uninit_petsc')
            end
            addpath(fullfile(petsc4m_root, 'CRS', 'mex'));
        end
    catch
        warning('Petsc4m:FailedInit', 'Failed to initialize petsc4m.')
        if exist('OCTAVE_VERSION', 'builtin')
            warning('Try to set LD_LIBRARY_PATH=$PETSC_DIR/lib in shell and restart Octave');
        end
    end
else
    warning('Petsc4m:NeedBuild', 'Please run build_petsc and then init_petsc again')
end

end

function tf = use_mexfiles
% Check whether it is safe to use MEX files

if exist('OCTAVE_VERSION', 'builtin') || ~usejava('jvm') && ismac
    tf = true;
    return
elseif usejava('jvm')
    tf = false;
    return
end

tf = true;

% Check LAPACK
[~, ~, ~, ~, ~, LIBDIR, LIBEXT] = obtain_petsc_cc;
[~, result] = system(['ldd ' LIBDIR '/libpetsc' LIBEXT '.so']);
liblapack = regexp(result, '\S+liblapack\.\S+', 'match', 'once');

missed = '';
if ~isempty(liblapack) && ~contains(getenv('LD_PRELOAD'), liblapack)
    tf = false;
    missed = [missed ':' liblapack];
end

% Check whether libmpi.so exists in matlabroot and whether it was preloaded
mpilib = dir(fullfile(matlabroot, 'bin', 'glnxa64', 'libmpi*.so.*'));
for i=1:length(mpilib)
    if contains(result, mpilib(i).name) && ~contains(getenv('LD_PRELOAD'), mpilib(i).name)
        tf = false;
        missed = [missed ':' mpilib(i).folder '/' mpilib(i).name]; %#ok<AGROW>
    end
end

if ~tf
    fprintf(1, 'Your LD_PRELOAD is %s.\n', getenv('LD_PRELOAD'));
    fprintf(1, 'To use MEX mode of PETSc, please add %s to LD_PRELOAD and restart MATLAB.\n', missed(2:end));
end
end
