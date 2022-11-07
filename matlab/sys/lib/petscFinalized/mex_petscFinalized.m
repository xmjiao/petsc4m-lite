function mex_petscFinalized
% Build script for petscFinalized

target = ['../../petscFinalized.' mexext];

if ~exist('isnewer', 'file') || ...
        ~isnewer(target, 'mex_petscFinalized.m', 'petscFinalized_mex.c')

    fprintf(1, 'Entering %s\n', pwd);

    % Get Petsc configuration
    [CC, ~, INC, CFLAGS, ~, LIBDIR, LIBEXT, LIBEXTRA] = obtain_petsc_cc();
    if ismac; CFLAGS = [CFLAGS ' -mmacosx-version-min=10.15']; end

    build_cmd = ['mex CC=' CC ' -I../../../include ' INC, ...
        ' CFLAGS=''' CFLAGS ' -Wno-unused-function $CFLAGS''' ...
        ' petscFinalized.c petscFinalized_mex.c -output ' target ...
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
