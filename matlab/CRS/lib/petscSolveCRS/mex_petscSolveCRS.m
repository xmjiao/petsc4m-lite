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
        ' LINKLIBS=''' dylibdir(LIBDIR) ' -lpetsc' LIBEXT ' ' LIBEXTRA ' $LINKLIBS'''];

    if exist('OCTAVE_VERSION', 'builtin')
        build_cmd = ['m' build_cmd];
    end
    disp(build_cmd);
    eval(build_cmd);
else
    fprintf(1, [target(length(fileparts(target)) - 3:end) ' is up to date.\n']);
end

end
