function build_petsc4m(varargin)

curpath = pwd;
cleanup = onCleanup(@()cd(curpath));
cd(petsc4m_root);

files = dir('sys/petscGet*.m');
for i = 1:length(files)
    base = files(i).name(1:end - 2);
    run(fullfile('sys', 'lib', base, ['mex_', base, '.m']));
end

if exist('OCTAVE_VERSION', 'builtin') || ~usejava('jvm') && ~isempty(getnenv('LD_PRELOAD'))
    run(fullfile('lib/petscSolveCRS/mex_petscSolveCRS.m'));
else
    % If running with MATLAB with JVM or without LD_PRELOAD, use exe files
    run(fullfile('lib/petscSolveCRS/build_petscSolveCRS_exe.m'));
end

end
