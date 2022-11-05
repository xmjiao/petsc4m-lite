function mex_petscSolveCRS
% Build script for petscSolveCRS

target = ['../../mex/petscSolveCRS.' mexext];

if ~exist('isnewer', 'file') || ...
        ~isnewer(target, 'mex_petscSolveCRS.m', 'petscSolveCRS_mex.c')

    fprintf(1, 'Entering %s\n', pwd);

    % Get Petsc configuration
    [CC, ~, INC, CFLAGS, ~, LIBDIR, LIBEXT, LIBEXTRA] = obtain_petsc_cc();
    if ismac; CFLAGS = [CFLAGS ' -mmacosx-version-min=10.15']; end

    build_cmd = ['mex CC=' CC ' -I../../../include ' INC, ...
        ' CFLAGS=''' CFLAGS ' -Wno-unused-function $CFLAGS''' ...
        ' petscSolveCRS.c petscSolveCRS_mex.c -output ' target ...
        ' LINKLIBS=''' dylibdir(LIBDIR) ' -lpetsc' LIBEXT ' $LINKLIBS -lmpi ' LIBEXTRA ''''];

    disp(build_cmd);
    if exist('OCTAVE_VERSION', 'builtin')
        status = unix(build_cmd, '-echo');
        if status; error('mex failed'); end
    else
        eval(build_cmd); %#ok<EVLEQ>
    end
else
    fprintf(1, [target(length(fileparts(target)) - 3:end) ' is up to date.\n']);
end

end
