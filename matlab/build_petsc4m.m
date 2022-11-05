function build_petsc4m(varargin)

curpath = pwd;
cleanup = onCleanup(@()cd(curpath));
cd(petsc4m_root);

files = [dir('sys/petscGet*.m'); dir('sys/petscInit*.m'); dir('sys/petscFinal*.m')];
for i = 1:length(files)
    base = files(i).name(1:end - 2);
    run(fullfile('sys', 'lib', base, ['mex_', base, '.m']));
end

run(fullfile('CRS/lib/petscSolveCRS/mex_petscSolveCRS.m'));
run(fullfile('CRS/lib/petscSolveCRS/build_petscSolveCRS_exe.m'));

end
