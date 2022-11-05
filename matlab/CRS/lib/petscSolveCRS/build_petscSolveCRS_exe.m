function build_petscSolveCRS_exe
% Build script for petscSolveCRS

exeext = strrep(mexext, 'mex', 'exe');
target = ['../../exe/petscSolveCRS.' exeext];

if ~exist('isnewer', 'file') || ...
        ~isnewer(target, 'build_petscSolveCRS_exe.m', 'petscSolveCRS_exe.c')

    fprintf(1, 'Entering %s\n', pwd);
    if exist('OCTAVE_VERSION', 'builtin')
        [~, output] = system('realpath `which mex`');
        if isempty(output); error('Could not locate mex.'); end
        MATLABROOT = output(1:end - 9);
    else
        MATLABROOT = matlabroot;
    end
    incdir = [MATLABROOT '/extern/include'];
    if isequal(computer, 'MACI64') || contains(computer, 'darwin')
        bindir = [MATLABROOT '/bin/maci64'];
        matlibs = ['-L' bindir ' -Wl,-rpath,' bindir ' -lmex -lmat -lmx -lm'];
    elseif isequal(computer, 'GLNXA64') || contains(computer, 'linux')
        bindir = [MATLABROOT '/bin/glnxa64'];
        matlibs = ['-L' bindir ' -Wl,-rpath=' bindir ' -lmex -lmat -lmx -lm'];
    else
        error('Building executable is not supported on %s\n', computer);
    end

    % Getting Petsc configuration
    [CC, ~, INC, CFLAGS, ~, LIBDIR, LIBEXT, LIBEXTRA] = obtain_petsc_cc();

    if ismac; CFLAGS = [CFLAGS ' -mmacosx-version-min=10.15']; end

    build_cmd = [CC ' ' CFLAGS ' ' INC, ...
        '-Wno-unused-function -DBUILD_MAT -I../../../include -I"' incdir ...
        '" petscSolveCRS.c petscSolveCRS_mex.c petscSolveCRS_exe.c -o ' target ...
        ' -L' LIBDIR ' -lmpi ' dylibdir(LIBDIR) ' -lpetsc' LIBEXT ' ' LIBEXTRA ' ' matlibs];

    disp(build_cmd);
    [status, cmdout] = system(build_cmd);
    if status
        error(cmdout)
    else
        fprintf(1, cmdout);
    end
else
    fprintf(1, [target(length(fileparts(target)) - 2:end) ' is up to date.\n']);
end

end
