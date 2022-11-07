function mex_petscGetEnum
% Build script for petscGetEnum

target = ['../../petscGetEnum.' mexext];

if ~exist('isnewer', 'file') || ...
        ~isnewer(target, 'mex_petscGetEnum.m', 'petscGetEnum_mex.c')

    fprintf(1, 'Entering %s\n', pwd);

    % Get Petsc configuration
    [CC, ~, INC, CFLAGS, ~, LIBDIR, LIBEXT, LIBEXTRA] = obtain_petsc_cc();
    if ismac; CFLAGS = [CFLAGS ' -mmacosx-version-min=10.15']; end

    build_cmd = ['mex CC=' CC ' -I../../../include ' INC, ...
        ' CFLAGS=''' CFLAGS ' -Wno-unused-function $CFLAGS''' ...
        ' petscGetEnum.c petscGetEnum_mex.c -output ' target ...
        ' LINKLIBS=''' dylibdir(LIBDIR) ' -lpetsc' LIBEXT ' ' LIBEXTRA ' $LINKLIBS'''];

    if exist('OCTAVE_VERSION', 'builtin')
        build_cmd = strrep(['m' build_cmd], 'CC=cc ', '');
    end
    disp(build_cmd);
    eval(build_cmd); %#ok<EVLEQ>
else
    fprintf(1, [target(length(fileparts(target)) + 2:end) ' is up to date.\n']);
end

end
