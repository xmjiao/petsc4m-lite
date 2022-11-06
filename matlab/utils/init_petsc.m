function init_petsc(varargin)
%INIT_PETSC Load Petsc4m-Lite into MATLAB/Octave for execution using mex files.

if exist(['petscInitialize.' mexext], 'file') && ...
    isequal(which('petscInitialize'), which(['petscInitialize.' mexext]))
    try
        if ~petscInitialized
            petscInitialize;

            if exist('OCTAVE_VERSION', 'builtin')
                atexit('uninit_petsc')
            end
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
