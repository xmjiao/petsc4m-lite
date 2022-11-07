function mex_petscGetSizeof
% Build script for petscGetSizeof

target = ['../../petscGetSizeof.' mexext];

if ~exist('isnewer', 'file') || ...
        ~isnewer(target, 'mex_petscGetSizeof.m', 'petscGetSizeof_mex.c')

    fprintf(1, 'Entering %s\n', pwd);

    % Get Petsc configuration
    [CC, ~, INC, CFLAGS, ~, LIBDIR, LIBEXT, LIBEXTRA] = obtain_petsc_cc();
    if ismac; CFLAGS = [CFLAGS ' -mmacosx-version-min=10.15']; end

    build_cmd = ['mex CC=' CC ' -I../../../include ' INC, ...
        ' CFLAGS=''' CFLAGS ' -Wno-unused-function $CFLAGS''' ...
        ' petscGetSizeof.c petscGetSizeof_mex.c -output ' target ...
        ' LINKLIBS=''' dylibdir(LIBDIR) ' -lpetsc' LIBEXT ' ' LIBEXTRA ' $LINKLIBS'''];

    if exist('OCTAVE_VERSION', 'builtin')
        build_cmd = ['m' build_cmd];
    end
    disp(build_cmd);
    eval(build_cmd); %#ok<EVLEQ>
else
    fprintf(1, [target(length(fileparts(target)) + 2:end) ' is up to date.\n']);
end

end
