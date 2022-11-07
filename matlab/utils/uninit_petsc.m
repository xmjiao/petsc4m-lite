function uninit_petsc
% Finalize PETSc.
% It is called automatically in Octave at exit if init_petsc was called

if exist('OCTAVE_VERSION', 'builtin')
    atexit('uninit_petsc', false)
end

if exist(['petscInitialized.' mexext], 'file') && ...
        petscInitialized && ~petscFinalized
    petscFinalize;
end

end
